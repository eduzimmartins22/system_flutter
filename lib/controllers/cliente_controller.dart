import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteController {
  static const String _baseUrl = 'http://192.168.0.6:8000/api'; 
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Buscar todos os clientes
  Future<List<Cliente>> getClientes() async {
    try {
      final url = Uri.parse('$_baseUrl/clientes');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Cliente.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão: $e');
    }
  }

  // Adicionar novo cliente
  Future<Cliente> adicionarCliente(Cliente cliente) async {
    try {
      // Verificar se o documento já existe
      final exists = await documentoExiste(cliente.cpfCnpj);
      if (exists) {
        throw Exception('Já existe um cliente com este documento');
      }

      final url = Uri.parse('$_baseUrl/clientes');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(cliente.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao criar cliente');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar cliente: $e');
    }
  }

  // Atualizar cliente existente
  Future<Cliente> atualizarCliente(Cliente cliente) async {
    try {
      // Verificar se existe outro cliente com o mesmo documento
      final exists = await documentoExiste(cliente.cpfCnpj, cliente.id);
      if (exists) {
        throw Exception('Já existe um cliente com este documento');
      }

      final url = Uri.parse('$_baseUrl/clientes/${cliente.id}');
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(cliente.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao atualizar cliente');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  // Remover cliente
  Future<bool> removerCliente(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/clientes/$id');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao remover cliente');
      }
    } catch (e) {
      throw Exception('Erro ao remover cliente: $e');
    }
  }

  // Buscar cliente por ID
  Future<Cliente?> buscarPorId(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/clientes/$id');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // Buscar cliente por documento
  Future<Cliente?> buscarPorDocumento(String documento) async {
    try {
      final url = Uri.parse('$_baseUrl/clientes/documento/$documento');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // Verificar se documento já existe
  Future<bool> documentoExiste(String documento, [int? idExcluir]) async {
    try {
      final cliente = await buscarPorDocumento(documento);
      
      if (cliente == null) {
        return false;
      }
      
      // Se está editando, verificar se não é o mesmo cliente
      if (idExcluir != null && cliente.id == idExcluir) {
        return false;
      }
      
      return true;
    } catch (e) {
      // Se der erro 404, significa que não existe
      if (e.toString().contains('404')) {
        return false;
      }
      throw e;
    }
  }

  // Buscar CEP usando o seu UseCase existente
  Future<Map<String, String>> buscarCep(String cep) async {
    final buscarCepUseCase = BuscarCepUseCase();
    return await buscarCepUseCase.execute(cep);
  }
}

// Sua classe existente do CEP
class BuscarCepUseCase {
  Future<Map<String, String>> execute(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('erro')) {
        throw Exception('CEP não encontrado.');
      }

      return {
        'endereco': data['logradouro'] ?? '',
        'bairro': data['bairro'] ?? '',
        'cidade': data['localidade'] ?? '',
        'uf': data['uf'] ?? '',
      };
    } else {
      throw Exception('Erro na consulta do CEP.');
    }
  }
}