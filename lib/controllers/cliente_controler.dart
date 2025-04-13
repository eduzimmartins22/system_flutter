import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cliente_model.dart';

class ClienteController {
  static const _clientesKey = 'lista_clientes';
  List<Cliente> _clientes = [];
  bool _listaCarregada = false;

  Future<void> _carregarLista() async {
    if (_listaCarregada) return;
    
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_clientesKey);
    
    if (jsonString != null) {
      try {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        _clientes = jsonList.map((json) => Cliente.fromJson(json)).toList();
      } catch (e) {
        _clientes = [];
      }
    }
    _listaCarregada = true;
  }

  Future<void> _salvarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _clientes.map((cliente) => cliente.toJson()).toList();
    await prefs.setString(_clientesKey, json.encode(jsonList));
    _listaCarregada = false;
  }

  Future<List<Cliente>> getClientes() async {
    await _carregarLista();
    return _clientes.toList();
  }

  Future<int> adicionarCliente(Cliente cliente) async {
    await _carregarLista();
    
    try {
      // Validações são feitas pelo próprio modelo ao criar
      final novoCliente = cliente.salvar();
      
      // Verifica se já existe cliente com este documento
      if (novoCliente.tipo == 'F' && _clientes.any((c) => c.cpf == novoCliente.cpf)) {
        throw Exception('Já existe um cliente com este CPF');
      }
      
      if (novoCliente.tipo == 'J' && _clientes.any((c) => c.cnpj == novoCliente.cnpj)) {
        throw Exception('Já existe um cliente com este CNPJ');
      }
      
      _clientes.add(novoCliente);
      await _salvarLista();
      return novoCliente.id!;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> atualizarCliente(Cliente cliente) async {
    await _carregarLista();
    
    try {
      final clienteAtualizado = cliente.salvar();
      final index = _clientes.indexWhere((c) => c.id == clienteAtualizado.id);
      
      if (index >= 0) {
        // Verifica se o documento foi alterado e se já existe
        if (clienteAtualizado.tipo == 'F' && 
            _clientes.any((c) => c.id != clienteAtualizado.id && c.cpf == clienteAtualizado.cpf)) {
          throw Exception('Já existe um cliente com este CPF');
        }
        
        if (clienteAtualizado.tipo == 'J' && 
            _clientes.any((c) => c.id != clienteAtualizado.id && c.cnpj == clienteAtualizado.cnpj)) {
          throw Exception('Já existe um cliente com este CNPJ');
        }
        
        _clientes[index] = clienteAtualizado;
        await _salvarLista();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
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
      return _clientes.firstWhere((c) => 
        (c.tipo == 'F' && c.cpf == documento) || 
        (c.tipo == 'J' && c.cnpj == documento));
    } catch (e) {
      return null;
    }
  }

  Future<bool> documentoExiste(String documento, [int? idExcluir]) async {
    await _carregarLista();
    return _clientes.any((c) => 
      (idExcluir == null || c.id != idExcluir) &&
      ((c.tipo == 'F' && c.cpf == documento) || 
       (c.tipo == 'J' && c.cnpj == documento)));
  }
}