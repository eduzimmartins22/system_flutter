import 'buscar_cep.dart';

class Cliente {
  final int? id;
  final String nome;
  final String tipo;
  final String? cpf;
  final String? cnpj;
  final String email;
  final int numero;
  final String cep;  
  final String endereco;
  final String bairro;
  final String cidade;
  final String uf;
//test
  Cliente({
    this.id,
    required this.nome,
    required this.tipo,
    this.cpf,
    this.cnpj,
    required this.email,
    required this.numero,
    required this.cep,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.uf,
  }) {
    if (tipo != 'F' && tipo != 'J') {
      throw ArgumentError('Tipo deve ser "F" (Física) ou "J" (Jurídica)');
    }
    if (tipo == 'F' && (cpf == null || cpf!.isEmpty)) {
      throw ArgumentError('CPF é obrigatório para pessoa física');
    }
    if (tipo == 'J' && (cnpj == null || cnpj!.isEmpty)) {
      throw ArgumentError('CNPJ é obrigatório para pessoa jurídica');
    }
    if (cpf != null && cpf!.length != 11) {
      throw ArgumentError('CPF deve ter 11 dígitos');
    }
    if (cnpj != null && cnpj!.length != 14) {
      throw ArgumentError('CNPJ deve ter 14 dígitos');
    }
  }

  Cliente salvar({int? idFornecido}) {
    final novoId = idFornecido ?? id ?? DateTime.now().millisecondsSinceEpoch;

    return Cliente(
      id: novoId,
      nome: nome,
      tipo: tipo,
      cpf: cpf,
      cnpj: cnpj,
      email: email,
      numero: numero,
      cep: cep,
      endereco: endereco,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? tipo,
    String? cpf,
    String? cnpj,
    String? email,
    int? numero,
    String? cep,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      numero: numero ?? this.numero,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    ).salvar();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'cpf': cpf,
      'cnpj': cnpj,
      'email': email,
      'numero': numero,
      'cep': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    };
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      cpf: json['cpf'] as String?,
      cnpj: json['cnpj'] as String?,
      email: json['email'] as String,
      numero: json['numero'] as int,
      cep: json['cep'] as String,
      endereco: json['endereco'] as String,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      uf: json['uf'] as String,
    ).salvar();
  }

  @override
  String toString() {
    return 'Cliente($id, $nome, $tipo, ${tipo == 'F' ? cpf : cnpj}, $email, $endereco, $numero, $cep, $bairro, $cidade, $uf)';
  }

  
  Future<Cliente> preencherEnderecoPorCep({
    String? enderecoManual,
    String? bairroManual,
    String? cidadeManual,
    String? ufManual,
  }) async {
    String novoEndereco = this.endereco;
    String novoBairro = this.bairro;
    String novaCidade = this.cidade;
    String novaUf = this.uf;

    final buscarCepUseCase = BuscarCepUseCase();

    try {
      final dadosEndereco = await buscarCepUseCase.execute(cep);
      novoEndereco = dadosEndereco['endereco']!;
      novoBairro = dadosEndereco['bairro']!;
      novaCidade = dadosEndereco['cidade']!;
      novaUf = dadosEndereco['uf']!;
    } catch (e) {
      print('Erro ao buscar CEP: $e');

      if (enderecoManual != null &&
          bairroManual != null &&
          cidadeManual != null &&
          ufManual != null) {
        novoEndereco = enderecoManual;
        novoBairro = bairroManual;
        novaCidade = cidadeManual;
        novaUf = ufManual;
      } else {
        print('Dados manuais não fornecidos. Mantendo dados atuais.');
      }
    }

    return this.copyWith(
      endereco: novoEndereco,
      bairro: novoBairro,
      cidade: novaCidade,
      uf: novaUf,
    );
  }
}
