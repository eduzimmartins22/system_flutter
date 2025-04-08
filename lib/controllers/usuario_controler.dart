import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/usuario_model.dart';

class UsuarioController {
  static const _usuariosKey = 'lista_usuarios';
  List<Usuario> _usuarios = [];
  bool _listaCarregada = false;

  Future<void> _carregarLista() async {
    if (_listaCarregada) return;
    
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usuariosKey);
    
    if (jsonString != null) {
      try {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        _usuarios = jsonList.map((json) => Usuario.fromJson(json)).toList();
      } catch (e) {
        _usuarios = [];
      }
    }
    _listaCarregada = true;
  }

  Future<void> _salvarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _usuarios.map((usuario) => usuario.toJson()).toList();
    await prefs.setString(_usuariosKey, json.encode(jsonList));
    _listaCarregada = false;
  }

  Future<List<Usuario>> getUsuarios() async {
    await _carregarLista();
    return _usuarios.toList();
  }

  Future<int> adicionarUsuario(String nome, String senha) async {
    await _carregarLista();
    
    // Verifica se já existe usuário com este nome
    if (_usuarios.any((u) => u.nome == nome)) {
      throw Exception('Nome de usuário já está em uso');
    }
    
    final novoId = _gerarNovoId();
    final novoUsuario = Usuario(
      id: novoId,
      nome: nome,
      senha: senha,
    );
    
    _usuarios.add(novoUsuario);
    await _salvarLista();
    return novoId;
  }

  Future<bool> atualizarUsuario(int id, String nome, String senha) async {
    await _carregarLista();
    
    final index = _usuarios.indexWhere((u) => u.id == id);
    if (index >= 0) {
      // Verifica se o novo nome já está em uso por outro usuário
      if (_usuarios.any((u) => u.id != id && u.nome == nome)) {
        throw Exception('Nome de usuário já está em uso');
      }
      
      _usuarios[index] = Usuario(
        id: id,
        nome: nome,
        senha: senha,
      );
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