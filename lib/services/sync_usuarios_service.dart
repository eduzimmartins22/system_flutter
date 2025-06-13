// ignore_for_file: collection_methods_unrelated_type

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class SyncUsuariosService {
  final UsuarioController _usuarioController = UsuarioController();

  Future<void> sincronizar(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Iniciando sincronização de usuarios...');
      await enviarUsuariosAPI(url, onLog: onLog);
      await deletarUsuariosAPI(url, onLog: onLog);
      await buscarUsuariosAPI(url, onLog: onLog);
      onLog?.call('Usuarios sincronizados com sucesso');
    } catch (e) {
      onLog?.call('Erro durante a sincronização: $e');
      rethrow;
    }
  }

  Future<void> enviarUsuariosAPI(String url, {Function(String)? onLog}) async {
    final usuarios = await _usuarioController.getUsuarios();
    if (usuarios.isEmpty) return;
    
    onLog?.call('Sincronizando ${usuarios.length} usuarios...');

    for (final usuario in usuarios) {
      try {
        if (usuario.ultimaAlteracao != null) {
          try {
            final response = await http.get(
              Uri.parse('$url/usuarios/${usuario.id}'),
              headers: {'Content-Type': 'application/json'},
            );

            if (response.statusCode == 200) {
              final usuarioServidor = Usuario.fromJson(json.decode(response.body));
              
              if (usuarioServidor.ultimaAlteracao != null && 
                  usuarioServidor.ultimaAlteracao!.isAfter(usuario.ultimaAlteracao!)) {
                await _usuarioController.upsertUsuarioFromServer(usuarioServidor);
                onLog?.call('Usuario ${usuario.id} atualizado localmente (versão do servidor mais recente)');
                continue;
              }
            }
          } catch (e) {
            onLog?.call('Erro ao verificar usuario ${usuario.id} no servidor: $e');
          }
        }

        final usuarioJson = usuario.toJson();
        final body = json.encode(usuarioJson);

        http.Response response;
        final bool isNovoUsuario = usuario.ultimaAlteracao == null;
        onLog?.call(isNovoUsuario ? 'é usuário novo' : 'não é novo usuário');

        if (isNovoUsuario) {
          response = await http.post(
            Uri.parse('$url/usuarios'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          response = await http.put(
            Uri.parse('$url/usuarios/${usuario.id}'),
            body: body,
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (response.body.isEmpty) continue;

        try {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _usuarioController.upsertUsuarioFromServer(Usuario.fromJson(decoded));
          } else {
            onLog?.call('Falha no ${isNovoUsuario ? 'envio' : 'update'} do usuario ${usuario.id} | Status: ${response.statusCode}');
          }
        } catch (e) {
          onLog?.call('Erro processando resposta do usuario ${usuario.id}: $e');
        }
      } catch (e) {
        onLog?.call('Erro crítico no usuario ${usuario.id}: $e');
      }
    }
  }

  Future<void> deletarUsuariosAPI(String url, {Function(String)? onLog}) async {
    final usuariosDeletados = await _usuarioController.getUsuariosDeletados();
    if (usuariosDeletados.isEmpty) return;

    onLog?.call('Deletando ${usuariosDeletados.length} usuarios...');

    for (final usuario in usuariosDeletados) {
      try {
        final response = await http.delete(Uri.parse('$url/usuarios/${usuario.id}'));
        
        if (response.statusCode == 200) {
          await _usuarioController.deletarUsuario(usuario.id);
        } else {
          onLog?.call('Falha ao deletar usuario ${usuario.id} | Status: ${response.statusCode}');
        }
      } catch (e) {
        onLog?.call('Erro crítico ao deletar usuario ${usuario.id}: $e');
      }
    }
  }

  Future<void> buscarUsuariosAPI(String url, {Function(String)? onLog}) async {
    try {
      onLog?.call('Buscando atualizações para usuarios...');
      final response = await http.get(Uri.parse('$url/usuarios'));

      if (response.statusCode != 200) {
        onLog?.call('Falha na busca | Status: ${response.statusCode}');
        return;
      }

      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      if (!responseBody.containsKey('dados')) {
        return;
      }

      final List<dynamic> dados = responseBody['dados'];
      if (dados.isEmpty) return;
      
      final Set<String> apiUsuarioIds = dados.map((usuario) => usuario['id'].toString()).toSet();
      final List<Usuario> localUsuariosWithChanges = await _usuarioController.getUsuariosComAlteracoes();

      for (final localUsuario in localUsuariosWithChanges) {
        if (!apiUsuarioIds.contains(localUsuario.id)) {
          try {
            await _usuarioController.deletarUsuario(localUsuario.id);
          } catch (e) {
            onLog?.call('Erro ao excluir localmente usuario ${localUsuario.id}: $e');
          }
        }
      }

      for (var usuarioJson in dados) {
        try {
          final usuarioServidor = Usuario.fromJson(usuarioJson);
          final usuarioLocal = await _usuarioController.buscarPorId(usuarioServidor.id);
          
          if (usuarioLocal != null && usuarioLocal.ultimaAlteracao != null) {
            if (usuarioServidor.ultimaAlteracao == null || 
                usuarioLocal.ultimaAlteracao!.isAfter(usuarioServidor.ultimaAlteracao!)) {
              onLog?.call('Usuario ${usuarioServidor.id} mantido local (versão local mais recente)');
              continue;
            }
          }
          
          await _usuarioController.upsertUsuarioFromServer(usuarioServidor);
        } catch (e) {
          onLog?.call('Erro processando usuario ${usuarioJson['id']}: $e');
        }
      }
    } catch (e) {
      onLog?.call('Erro crítico na busca: $e');
      rethrow;
    }
  }
}