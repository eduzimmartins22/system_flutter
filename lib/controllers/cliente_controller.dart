import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cliente_model.dart';

class ClienteController {
  static const _clientesKey = 'lista_clientes';
  List<Cliente> _clientes = [];

  Future<void> _carregarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_clientesKey);
    
    if (jsonString != null) {
      try {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        _clientes = jsonList.map((json) => Cliente.fromJson(json)).toList();
      } catch (e) {
        _clientes = [];
      }
    } else {
      _clientes = [];
    }
  }

  Future<void> _salvarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _clientes.map((cliente) => cliente.toJson()).toList();
    await prefs.setString(_clientesKey, json.encode(jsonList));
  }

  Future<List<Cliente>> getClientes() async {
    await _carregarLista();
    return _clientes.toList();
  }

  Future<int> adicionarCliente(Cliente cliente) async {
    await _carregarLista();
    
    if (_clientes.any((c) => c.cpfCnpj == cliente.cpfCnpj)) {
      throw Exception('Já existe um cliente com este documento');
    }
    
    if (_clientes.any((c) => c.id == cliente.id)) {
      final novoCliente = cliente.copyWith(id: _gerarNovoId());
      _clientes.add(novoCliente);
    } else {
      _clientes.add(cliente);
    }
    
    await _salvarLista();
    return cliente.id;
  }

  Future<bool> atualizarCliente(Cliente cliente) async {
    await _carregarLista();
    
    final index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index >= 0) {
      if (_clientes.any((c) => c.id != cliente.id && c.cpfCnpj == cliente.cpfCnpj)) {
        throw Exception('Já existe um cliente com este documento');
      }
      
      _clientes[index] = cliente;
      await _salvarLista();
      return true;
    }
    return false;
  }

  Future<bool> removerCliente(int id) async {
    await _carregarLista();
    
    final initialLength = _clientes.length;
    _clientes.removeWhere((cliente) => cliente.id == id);
    final removed = initialLength != _clientes.length;
    
    if (removed) {
      await _salvarLista();
    }
    return removed;
  }

  Future<Cliente?> buscarPorId(int id) async {
    await _carregarLista();
    try {
      return _clientes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Cliente?> buscarPorDocumento(String documento) async {
    await _carregarLista();
    try {
      return _clientes.firstWhere((c) => c.cpfCnpj == documento);
    } catch (e) {
      return null;
    }
  }

  Future<bool> documentoExiste(String documento, [int? idExcluir]) async {
    await _carregarLista();
    return _clientes.any((c) => 
      (idExcluir == null || c.id != idExcluir) &&
      c.cpfCnpj == documento);
  }

  int _gerarNovoId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}