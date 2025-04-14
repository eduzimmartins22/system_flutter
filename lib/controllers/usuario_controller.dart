import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/usuario_model.dart';

class UsuarioController {
  static const _usuariosKey = 'lista_usuarios';
  List<Usuario> _usuarios = [];

  Future<void> _carregarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usuariosKey);
    
    if (jsonString != null) {
      try {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        _usuarios = jsonList.map((json) => Usuario.fromJson(json)).toList();
      } catch (e) {
        _usuarios = [];
      }
    } else {
      _usuarios = [];
    }
  }

  Future<void> _salvarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _usuarios.map((usuario) => usuario.toJson()).toList();
    await prefs.setString(_usuariosKey, json.encode(jsonList));
  }

  Future<List<Usuario>> getUsuarios() async {
    await _carregarLista();
    return _usuarios.toList();
  }

  Future<int> adicionarUsuario(Usuario usuario) async {
    await _carregarLista();
    
    if (_usuarios.any((u) => u.nome == usuario.nome)) {
      throw Exception('Já existe um usuário com este nome');
    }
    
    if (_usuarios.any((u) => u.id == usuario.id)) {
      final novoUsuario = usuario.copyWith(id: _gerarNovoId());
      _usuarios.add(novoUsuario);
    } else {
      _usuarios.add(usuario);
    }
    
    await _salvarLista();
    return usuario.id;
  }

  Future<bool> atualizarUsuario(Usuario usuario) async {
    await _carregarLista();
    
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index >= 0) {
      if (_usuarios.any((u) => u.id != usuario.id && u.nome == usuario.nome)) {
        throw Exception('Já existe um usuário com este nome');
      }
      
      _usuarios[index] = usuario;
      await _salvarLista();
      return true;
    }
    return false;
  }

  Future<bool> removerUsuario(int id) async {
    await _carregarLista();
    
    final initialLength = _usuarios.length;
    _usuarios.removeWhere((usuario) => usuario.id == id);
    final removed = initialLength != _usuarios.length;
    
    if (removed) {
      await _salvarLista();
    }
    return removed;
  }

  Future<Usuario?> buscarPorId(int id) async {
    await _carregarLista();
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Usuario?> buscarPorNomeESenha(String nome, String senha) async {
    await _carregarLista();
    try {
      return _usuarios.firstWhere((u) => u.nome == nome && u.senha == senha);
    } catch (e) {
      return null;
    }
  }

  Future<bool> nomeUsuarioExiste(String nome) async {
    await _carregarLista();
    return _usuarios.any((u) => u.nome == nome);
  }

  int _gerarNovoId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}