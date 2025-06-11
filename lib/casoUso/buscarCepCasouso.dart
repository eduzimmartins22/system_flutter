import 'package:sistem_flutter/controllers/buscar_cep.dart';

class BuscarCepUseCase {
  final ViaCepService _viaCepService = ViaCepService();

  Future<Map<String, String>> execute(String cep) async {
    final data = await _viaCepService.consultarCep(cep);

    return {
      'endereco': data['logradouro'] ?? '',
      'bairro': data['bairro'] ?? '',
      'cidade': data['localidade'] ?? '',
      'uf': data['uf'] ?? '',
    };
  }
}
