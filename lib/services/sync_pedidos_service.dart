// ignore_for_file: collection_methods_unrelated_type

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/pedido_controller.dart';
import '../models/pedido_model.dart';

class SyncPedidosService {
  final PedidoController _pedidoController = PedidoController();

  Future<void> sincronizar(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Iniciando sincronização de pedidos...');
      await enviarPedidosAPI(url, onLog: onLog);
      await deletarPedidosAPI(url, onLog: onLog);
      await buscarPedidosAPI(url, onLog: onLog);
      onLog?.call('Pedidos sincronizados com sucesso');
    } catch (e) {
      onLog?.call('Erro durante a sincronização: $e');
      rethrow;
    }
  }

  Future<void> enviarPedidosAPI(String url, {Function(String)? onLog}) async {
    final pedidos = await _pedidoController.listarPedidosCompletos();
    if (pedidos.isEmpty) return;

    onLog?.call('Sincronizando ${pedidos.length} pedidos...');

    for (final pedido in pedidos) {
      try {
        if (pedido.id != 0 && pedido.ultimaAlteracao != null) {
          try {
            final response = await http.get(
              Uri.parse('$url/pedidos/${pedido.id}'),
              headers: {'Content-Type': 'application/json'},
            );

            if (response.statusCode == 200) {
              final pedidoServidor = Pedido.fromJson(
                json.decode(response.body),
              );

              if (pedidoServidor.ultimaAlteracao != null &&
                  pedidoServidor.ultimaAlteracao!.isAfter(pedido.ultimaAlteracao!)) {
                await _pedidoController.atualizarPedidoCompleto(pedidoServidor);
                continue;
              }
            }
          } catch (e) {
            onLog?.call('Erro ao verificar pedido ${pedido.id} no servidor: $e');
          }
        }

        final pedidoParaEnvio = pedido.copyWith(
          ultimaAlteracao: pedido.id == 0 ? null : pedido.ultimaAlteracao
        );
        
        final pedidoJson = pedidoParaEnvio.toJson();
        final body = json.encode(pedidoJson);

        onLog?.call('pedido ID:${pedido.id} -> $body');
        final response = await http.post(
          Uri.parse('$url/pedidos'),
          body: body,
          headers: {'Content-Type': 'application/json'},
        );

        onLog?.call('response -> $body');

        if (response.body.isEmpty) continue;

        try {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          if (response.statusCode >= 200 && response.statusCode < 300) {
            final pedidoAtualizado = Pedido.fromJson(decoded);
            await _pedidoController.atualizarPedidoCompleto(pedidoAtualizado);
          } else {
            onLog?.call('Falha no envio do pedido ${pedido.id} | Status: ${response.statusCode}');
          }
        } catch (e) {
          onLog?.call('Erro processando resposta do pedido ${pedido.id}: $e');
        }
      } catch (e) {
        onLog?.call('Erro crítico no pedido ${pedido.id}: $e');
      }
    }
  }

  Future<void> deletarPedidosAPI(String url, {Function(String)? onLog}) async {
    final pedidosDeletados = await _pedidoController.listarPedidosDeletados();
    if (pedidosDeletados.isEmpty) return;

    onLog?.call('Deletando ${pedidosDeletados.length} pedidos...');

    for (final pedido in pedidosDeletados) {
      try {
        final response = await http.delete(
          Uri.parse('$url/pedidos/${pedido.id}'),
        );

        if (response.statusCode == 200) {
          await _pedidoController.deletarPedido(pedido.id);
        } else {
          onLog?.call(
            'Falha ao deletar pedido ${pedido.id} | Status: ${response.statusCode}',
          );
        }
      } catch (e) {
        onLog?.call('Erro crítico ao deletar pedido ${pedido.id}: $e');
      }
    }
  }

  Future<void> buscarPedidosAPI(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Buscando atualizações para pedidos...');
      final response = await http.get(Uri.parse('$url/pedidos'));

      if (response.statusCode != 200) {
        onLog?.call('Falha na busca | Status: ${response.statusCode}');
        return;
      }

      final responseBody = json.decode(response.body);
      List<dynamic> dados;
      
      if (responseBody is Map && responseBody.containsKey('dados')) {
        dados = responseBody['dados'] as List<dynamic>;
      } else {
        onLog?.call('Formato de resposta inesperado: $responseBody');
        return;
      }

      if (dados.isEmpty) return;
      
      for (var pedidoJson in dados) {
        try {
          final pedidoServidor = Pedido.fromJson(pedidoJson);
          Pedido? pedidoLocal;
          
          try {
            pedidoLocal = (await _pedidoController.listarPedidosCompletos())
                .firstWhere((p) => p.id == pedidoServidor.id);
          } catch (e) {
            pedidoLocal = null;
          }
          
          if (pedidoLocal != null && pedidoLocal.ultimaAlteracao != null) {
            if (pedidoServidor.ultimaAlteracao == null || 
              pedidoLocal.ultimaAlteracao!.isAfter(pedidoServidor.ultimaAlteracao!)) {
              continue;
            }
          }
          
          if (pedidoLocal == null) {
            await _pedidoController.criarPedidoCompleto(pedidoServidor);
          } else {
            await _pedidoController.atualizarPedidoCompleto(pedidoServidor);
          }
        } catch (e) {
          onLog?.call('Erro processando pedido ${pedidoJson['id']}: $e');
        }
      }
    } catch (e) {
      onLog?.call('Erro crítico na busca: $e');
      rethrow;
    }
  }
}
