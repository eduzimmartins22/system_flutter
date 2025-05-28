import 'dart:convert';
import 'package:http/http.dart' as http;

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
