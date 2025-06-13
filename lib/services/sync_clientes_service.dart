// ignore_for_file: collection_methods_unrelated_type

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/cliente_controller.dart';
import '../models/cliente_model.dart';

class SyncClientesService {
  final ClienteController _clienteController = ClienteController();

  Future<void> sincronizar(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Iniciando sincronização de clientes...');
      await enviarClientesAPI(url, onLog: onLog);
      await deletarClientesAPI(url, onLog: onLog);
      await buscarClientesAPI(url, onLog: onLog);
      onLog?.call('Clientes sincronizados com sucesso');
    } catch (e) {
      onLog?.call('Erro durante a sincronização: $e');
      rethrow;
    }
  }

  Future<void> enviarClientesAPI(String url, {Function(String)? onLog}) async {
    final clientes = await _clienteController.getClientes();
    if (clientes.isEmpty) return;
    
    onLog?.call('Sincronizando ${clientes.length} clientes...');

    for (final cliente in clientes) {
      try {
        if (cliente.ultimaAlteracao != null) {
          try {
            final response = await http.get(
              Uri.parse('$url/clientes/${cliente.id}'),
              headers: {'Content-Type': 'application/json'},
            );

            if (response.statusCode == 200) {
              final clienteServidor = Cliente.fromJson(json.decode(response.body));
              
              if (clienteServidor.ultimaAlteracao != null && 
                  clienteServidor.ultimaAlteracao!.isAfter(cliente.ultimaAlteracao!)) {
                await _clienteController.upsertClienteFromServer(clienteServidor);
                continue;
              } else if (clienteServidor.ultimaAlteracao != null &&
                  clienteServidor.ultimaAlteracao!.isBefore(cliente.ultimaAlteracao!)) {
                await http.put(
                  Uri.parse('$url/clientes/${cliente.id}'),
                  body: json.encode(cliente.toJson()),
                  headers: {'Content-Type': 'application/json'},
                );
                continue;
              }
            }
          } catch (e) {
            onLog?.call('Cliente ${cliente.id} não existe mais no servidor.');
          }
        }

        final clienteJson = cliente.toJson();
        final body = json.encode(clienteJson);

        http.Response response;
        final bool isNovoCliente = cliente.ultimaAlteracao == null;

        if (isNovoCliente) {
          response = await http.post(
            Uri.parse('$url/clientes'),
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
            await _clienteController.upsertClienteFromServer(Cliente.fromJson(decoded));
          } else {
            onLog?.call('Falha no ${isNovoCliente ? 'envio' : 'update'} do cliente ${cliente.id} | Status: ${response.statusCode}');
          }
        } catch (e) {
          onLog?.call('Erro processando resposta do cliente ${cliente.id}: $e');
        }
      } catch (e) {
        onLog?.call('Erro crítico no cliente ${cliente.id}: $e');
      }
    }
  }

  Future<void> deletarClientesAPI(String url, {Function(String)? onLog}) async {
    final clientesDeletados = await _clienteController.getClientesDeletados();
    if (clientesDeletados.isEmpty) return;

    onLog?.call('Deletando ${clientesDeletados.length} clientes...');

    for (final cliente in clientesDeletados) {
      try {
        final response = await http.delete(Uri.parse('$url/clientes/${cliente.id}'));
        
        if (response.statusCode == 200) {
          await _clienteController.deletarCliente(cliente.id);
        } else {
          onLog?.call('Falha ao deletar cliente ${cliente.id} | Status: ${response.statusCode}');
        }
      } catch (e) {
        onLog?.call('Erro crítico ao deletar cliente ${cliente.id}: $e');
      }
    }
  }

  Future<void> buscarClientesAPI(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Buscando atualizações para clientes...');
      final response = await http.get(Uri.parse('$url/clientes'));

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
      
      final Set<String> apiClienteIds = dados.map((cliente) => cliente['id'].toString()).toSet();
      
      final List<Cliente> clientesLocais = await _clienteController.getClientes();
      
      for (final clienteLocal in clientesLocais) {
        if (clienteLocal.ultimaAlteracao != null && !apiClienteIds.contains(clienteLocal.id)) {
          try {
            await _clienteController.deletarCliente(clienteLocal.id);
          } catch (e) {
            onLog?.call('Erro ao excluir localmente cliente ${clienteLocal.id}: $e');
          }
        }
      }

      for (var clienteJson in dados) {
        try {
          final clienteServidor = Cliente.fromJson(clienteJson);
          final clienteLocal = await _clienteController.buscarPorId(clienteServidor.id);
          
          if (clienteLocal != null && clienteLocal.ultimaAlteracao != null) {
            if (clienteServidor.ultimaAlteracao == null || 
                clienteLocal.ultimaAlteracao!.isAfter(clienteServidor.ultimaAlteracao!)) {
              continue;
            }
          }
          
          await _clienteController.upsertClienteFromServer(clienteServidor);
        } catch (e) {
          onLog?.call('Erro processando cliente ${clienteJson['id']}: $e');
        }
      }
    } catch (e) {
      onLog?.call('Erro crítico na busca: $e');
      rethrow;
    }
  }
}