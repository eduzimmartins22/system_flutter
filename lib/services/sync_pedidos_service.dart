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
        if (pedido.deletado == 1) continue;

        final Map<String, dynamic> pedidoJson = _pedidoController
            .formatarParaServidor(pedido);
        final body = json.encode(pedidoJson);

        http.Response response;
        final bool isNovoPedido = pedido.ultimaAlteracao == null;

        if (isNovoPedido) {
          response = await http.post(
            Uri.parse('$url/pedidos'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        } 
        else {
          final pedidoServidor = await http.get(
            Uri.parse('$url/pedidos/${pedido.id}'),
          );
          
          if (pedidoServidor.statusCode == 200) {
            final pedidoJsonServidor = json.decode(pedidoServidor.body);
            
            if (DateTime.parse(pedidoJsonServidor['ultimaAlteracao'],).isBefore(pedido.ultimaAlteracao!)) {
              response = await http.post(
                Uri.parse('$url/pedidos'),
                body: body,
                headers: {'Content-Type': 'application/json'},
              );
            }
          }
          continue;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isNotEmpty) {
            try {
              final decoded = json.decode(response.body);
              await _pedidoController.upsertPedidoFromServer(
                Pedido.fromJson(decoded),
              );
            } catch (e) {
              onLog?.call('Erro ao processar resposta: $e');
            }
          }
        } else {
          onLog?.call('''
          Falha ao sincronizar pedido ${pedido.id} 
          Status: ${response.statusCode}
          Resposta: ${response.body}''');
        }
      } catch (e) {
        await _pedidoController.deletarPedido(pedido.id);
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

      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      if (!responseBody.containsKey('dados')) {
        onLog?.call('Resposta inválida da API: ausência de "dados"');
        return;
      }

      final List<dynamic> dados = responseBody['dados'];
      
      final Set<String> serverPedidoIds = dados.map((p) => p['id'].toString()).toSet();
      
      final List<Pedido> pedidosLocaisSincronizados = (await _pedidoController.listarPedidosCompletos())
        .where((pedido) => pedido.ultimaAlteracao != null)
        .toList();

      for (final pedidoLocal in pedidosLocaisSincronizados) {
        if (!serverPedidoIds.contains(pedidoLocal.id)) {
          try {
            await _pedidoController.deletarPedido(pedidoLocal.id);
          } catch (e) {
            onLog?.call('Erro ao excluir localmente pedido ${pedidoLocal.id}: $e');
          }
        }
      }

      for (var pedidoJson in dados) {
        try {
          final pedidoServidor = Pedido.fromJson(pedidoJson);
          final pedidoLocal = await _pedidoController.getPedidoById(pedidoServidor.id);
          
          if (pedidoJson['deletado'] == true || pedidoJson['deletado'] == 1) {
            if (pedidoLocal != null) {
              await _pedidoController.deletarPedido(pedidoLocal.id);
            }
            continue;
          }
          
          if (pedidoLocal != null && 
              pedidoLocal.ultimaAlteracao != null &&
              pedidoServidor.ultimaAlteracao != null &&
              pedidoLocal.ultimaAlteracao!.isAfter(pedidoServidor.ultimaAlteracao!)) {
            continue;
          }
          
          await _pedidoController.upsertPedidoFromServer(pedidoServidor);
        } catch (e) {
          onLog?.call('Erro processando pedido ${pedidoJson['id']}: $e | JSON: $pedidoJson');
        }
      }
    } catch (e) {
      onLog?.call('Erro crítico na busca: $e');
      rethrow;
    }
  }
}
