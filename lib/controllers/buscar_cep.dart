import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  Future<Map<String, dynamic>> consultarCep(String cep) async {
    if (!RegExp(r'^\d{8}$').hasMatch(cep)) {
      throw Exception('Formato de CEP inválido.');
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    final response = await http.get(url).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('erro')) {
        throw Exception('CEP não encontrado.');
      }
      return data;
    } else {
      throw Exception('Erro na consulta do CEP: ${response.statusCode}');
    }
  }
}
