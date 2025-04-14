class Cliente {
  final int id;
  final String nome;
  final TipoCliente tipo;
  final String cpfCnpj;
  final String? email;
  final int? numero;
  final int? cep;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? uf;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.numero,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
  }) {
    if (tipo == TipoCliente.fisica && cpfCnpj.length != 11) {
      throw ArgumentError('CPF deve ter 11 dígitos');
    }
    
    if (tipo == TipoCliente.juridica && cpfCnpj.length != 14) {
      throw ArgumentError('CNPJ deve ter 14 dígitos');
    }
  }

  Cliente copyWith({
    int? id,
    String? nome,
    TipoCliente? tipo,
    String? cpfCnpj,
    String? email,
    int? numero,
    int? cep,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      email: email ?? this.email,
      numero: numero ?? this.numero,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.name,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'numero': numero,
      'cep': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    }..removeWhere((key, value) => value == null);
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int,
      nome: json['nome'] as String,
      tipo: TipoCliente.values.byName(json['tipo'] as String),
      cpfCnpj: json['cpfCnpj'] as String,
      email: json['email'] as String?,
      numero: json['numero'] as int?,
      cep: json['cep'] as int?,
      endereco: json['endereco'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
    );
  }

  @override
  String toString() {
    return 'Cliente($id, $nome, ${tipo.descricao}, $cpfCnpj, $email, $endereco, $numero, $cep, $bairro, $cidade, $uf)';
  }
}

enum TipoCliente {
  fisica('Pessoa Física'),
  juridica('Pessoa Jurídica');

  final String descricao;
  const TipoCliente(this.descricao);
}