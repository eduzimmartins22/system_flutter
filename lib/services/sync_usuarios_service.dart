import 'dart:convert';

import 'package:http/http.dart' as http;
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class SyncUsuariosService {
  final UsuarioController _usuarioController = UsuarioController();

  Future<void> sincronizar(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('1. Enviando alterações locais para a API...');
      await enviarUsuariosAPI(url, onLog: onLog);
      
      onLog?.call('2. Deletando registros marcados como deletados localmente...');
      await deletarUsuariosAPI(url, onLog: onLog);
      
      onLog?.call('3. Buscando atualizações da API...');
      await buscarUsuariosAPI(url, onLog: onLog);
      
      onLog?.call('Sincronização de usuários concluída com sucesso');
    } catch (e) {
      onLog?.call('Erro durante a sincronização: $e');
      rethrow;
    }
  }

  Future<void> enviarUsuariosAPI(String url, {Function(String)? onLog}) async {
    final usuarios = await _usuarioController.getUsuarios();
    onLog?.call('Encontrados ${usuarios.length} usuários locais para sincronizar');

    for (final usuario in usuarios) {
      try {
        final usuarioJson = usuario.toJson();
        final body = json.encode(usuarioJson);

        http.Response response;
        String operation;

        if (usuario.ultimaAlteracao == null) {
          operation = 'criação';
          onLog?.call('Enviando novo usuário (ID local: ${usuario.id})...');
          response = await http.post(
            Uri.parse('$url/usuarios'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          operation = 'atualização';
          onLog?.call('Atualizando usuário existente (ID: ${usuario.id})...');
          response = await http.put(
            Uri.parse('$url/usuarios/${usuario.id}'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Verifica se a resposta tem corpo
        if (response.body.isEmpty) {
          onLog?.call('Aviso: Resposta vazia na $operation do usuário ${usuario.id}');
          continue;
        }

        try {
          final dynamic decoded = json.decode(response.body);
          if (decoded is! Map<String, dynamic>) {
            onLog?.call('Resposta não é um Map<String, dynamic>. Tipo recebido: ${decoded.runtimeType}');
            return; // ou trate o erro conforme necessário
          }
          final responseBody = decoded;
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            final usuarioResponse = Usuario.fromJson(responseBody);
            await _usuarioController.upsertUsuarioFromServer(usuarioResponse);
            onLog?.call('Sucesso na $operation do usuário ${usuario.id}');
          } else {
            onLog?.call('Erro na $operation do usuário ${usuario.id}. Status: ${response.statusCode}');
            onLog?.call('Resposta: ${response.body}');
          }
        } catch (e) {
          onLog?.call('Erro ao processar resposta na $operation do usuário ${usuario.id}: $e');
          onLog?.call('Resposta bruta: ${response.body}');
        }
      } catch (e) {
        onLog?.call('Erro na comunicação durante o envio do usuário ${usuario.id}: $e');
      }
    }
  }

  Future<void> deletarUsuariosAPI(String url, {Function(String)? onLog}) async {
    final usuariosDeletados = await _usuarioController.getUsuariosDeletados();
    onLog?.call('Encontrados ${usuariosDeletados.length} usuários marcados para exclusão');

    for (final usuario in usuariosDeletados) {
      try {
        onLog?.call('Deletando usuário da API (ID: ${usuario.id})...');
        final response = await http.delete(
          Uri.parse('$url/usuarios/${usuario.id}'),
        );

        if (response.statusCode == 200) {
          await _usuarioController.deletarUsuario(usuario.id);
          onLog?.call('Usuário deletado com sucesso (ID: ${usuario.id})');
        }
      } catch (e) {
        onLog?.call('Erro ao deletar usuário ${usuario.id} da API: $e');
      }
    }
  }

  Future<void> buscarUsuariosAPI(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Buscando usuários ativos da API...');
      final response = await http.get(Uri.parse('$url/usuarios'));

      onLog?.call('Status code: ${response.statusCode}');
      onLog?.call('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Verifica se a resposta contém a chave 'dados'
        if (responseBody.containsKey('dados')) {
          final List<dynamic> dados = responseBody['dados'];
          
          onLog?.call('Encontrados ${dados.length} usuários na resposta');
          
          // Obter todos os IDs da API
          final Set<String> apiUserIds = dados.map((user) => user['id'].toString()).toSet();
          
          // Obter usuários locais que foram alterados (tem ultimaAlteracao)
          final List<Usuario> localUsersWithChanges = await _usuarioController.getUsuariosComAlteracoes();
          
          onLog?.call('Encontrados ${localUsersWithChanges.length} usuários locais com alterações');
          
          // Verificar quais usuários locais não existem na API
          for (final localUser in localUsersWithChanges) {
            if (!apiUserIds.contains(localUser.id)) {
              onLog?.call('Usuário local (ID: ${localUser.id}) não encontrado na API - marcando para exclusão local');
              await _usuarioController.deletarUsuario(localUser.id);
            }
          }
          
          // Processar os usuários da API normalmente
          for (var usuarioJson in dados) {
            try {
              // Converte cada usuário e trata campos nulos
              final Usuario usuario = Usuario.fromJson(usuarioJson);
              await _usuarioController.upsertUsuarioFromServer(usuario);
              onLog?.call('Usuário ${usuario.id} processado com sucesso');
            } catch (e) {
              onLog?.call('Erro ao processar usuário: $e\nDados: $usuarioJson');
            }
          }
        } else {
          onLog?.call('Resposta da API não contém a chave "dados"');
        }
      } else {
        onLog?.call('Erro na resposta da API: ${response.statusCode}');
      }
    } catch (e) {
      onLog?.call('Erro ao buscar usuários da API: $e');
      rethrow;
    }
  }
}