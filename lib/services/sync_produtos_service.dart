// ignore_for_file: collection_methods_unrelated_type

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/produto_controller.dart';
import '../models/produto_model.dart';

class SyncProdutosService {
  final ProdutoController _produtoController = ProdutoController();

  Future<void> sincronizar(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Iniciando sincronização de produtos...');
      await enviarProdutosAPI(url, onLog: onLog);
      await deletarProdutosAPI(url, onLog: onLog);
      await buscarProdutosAPI(url, onLog: onLog);
      onLog?.call('Produtos sincronizados com sucesso');
    } catch (e) {
      onLog?.call('Erro durante a sincronização: $e');
      rethrow;
    }
  }

  Future<void> enviarProdutosAPI(String url, {Function(String)? onLog}) async {
    final produtos = await _produtoController.getProdutos();
    if (produtos.isEmpty) return;
    
    onLog?.call('Sincronizando ${produtos.length} produtos...');

    for (final produto in produtos) {
      try {
        if (produto.ultimaAlteracao != null) {
          try {
            final response = await http.get(
              Uri.parse('$url/produtos/${produto.id}'),
              headers: {'Content-Type': 'application/json'},
            );

            if (response.statusCode == 200) {
              final produtoServidor = Produto.fromJson(json.decode(response.body));
              
              if (produtoServidor.ultimaAlteracao!.isAfter(produto.ultimaAlteracao!)) {
                await _produtoController.upsertProdutoFromServer(produtoServidor);
                onLog?.call('Produto ${produto.id} atualizado localmente (versão do servidor mais recente)');
                continue;
              }
            }
          } catch (e) {
            onLog?.call('Erro ao verificar produto ${produto.id} no servidor: $e');
          }
        }

        final produtoJson = produto.toJson();
        final body = json.encode(produtoJson);

        http.Response response;
        final bool isNovoProduto = produto.ultimaAlteracao == null;

        if(isNovoProduto) {
          response = await http.post(
            Uri.parse('$url/produtos/'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          continue;
        }
        
        if (response.body.isEmpty) continue;

        try {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _produtoController.upsertProdutoFromServer(Produto.fromJson(decoded));
          } else {
            onLog?.call('Falha no ${isNovoProduto ? 'envio' : 'update'} do produto ${produto.id} | Status: ${response.statusCode}');
          }
        } catch (e) {
          onLog?.call('Erro processando resposta do produto ${produto.id}: $e');
        }
      } catch (e) {
        onLog?.call('Erro crítico no produto ${produto.id}: $e');
      }
    }
  }

  Future<void> deletarProdutosAPI(String url, {Function(String)? onLog}) async {
    final produtosDeletados = await _produtoController.getProdutosDeletados();
    if (produtosDeletados.isEmpty) return;

    onLog?.call('Deletando ${produtosDeletados.length} produtos...');

    for (final produto in produtosDeletados) {
      try {
        final response = await http.delete(Uri.parse('$url/produtos/${produto.id}'));
        
        if (response.statusCode == 200) {
          await _produtoController.deletarProduto(produto.id);
        } else {
          onLog?.call('Falha ao deletar produto ${produto.id} | Status: ${response.statusCode}');
        }
      } catch (e) {
        onLog?.call('Erro crítico ao deletar produto ${produto.id}: $e');
      }
    }
  }

  Future<void> buscarProdutosAPI(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Buscando atualizações para produtos...');
      final response = await http.get(Uri.parse('$url/produtos'));

      if (response.statusCode != 200) {
        onLog?.call('Falha na busca | Status: ${response.statusCode}');
        return;
      }

      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      if (!responseBody.containsKey('dados')) {
        onLog?.call('Resposta inválida da API: ausência de "dados"');
        return;
      }

      final List<dynamic> dados = responseBody['dados'];
      if (dados.isEmpty) return;
      
      final Set<String> apiProdutoIds = dados.map((produto) => produto['id'].toString()).toSet();
      final List<Produto> localProdutosWithChanges = await _produtoController.getProdutosComAlteracoes();

      for (final localProduto in localProdutosWithChanges) {
        if (!apiProdutoIds.contains(localProduto.id)) {
          try {
            await _produtoController.deletarProduto(localProduto.id);
          } catch (e) {
            onLog?.call('Erro ao excluir localmente produto ${localProduto.id}: $e');
          }
        }
      }

      for (var produtoJson in dados) {
        try {
          final produtoServidor = Produto.fromJson(produtoJson);
          final produtoLocal = await _produtoController.getProdutoPorId(produtoServidor.id);
          
          if (produtoLocal != null && produtoLocal.ultimaAlteracao != null) {
            if (produtoServidor.ultimaAlteracao == null || 
                produtoLocal.ultimaAlteracao!.isAfter(produtoServidor.ultimaAlteracao!)) {
              onLog?.call('Produto ${produtoServidor.id} mantido local (versão local mais recente)');
              continue;
            }
          }
          
          await _produtoController.upsertProdutoFromServer(produtoServidor);
        } catch (e) {
          onLog?.call('Erro processando produto ${produtoJson['id']}: $e');
        }
      }
    } catch (e) {
      onLog?.call('Erro crítico na busca: $e');
      rethrow;
    }
  }
}