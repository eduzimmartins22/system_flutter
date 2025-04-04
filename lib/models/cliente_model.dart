class Cliente {
  final int? id; // Agora é opcional
  final String nome;
  final String tipo;
  final String? cpf;
  final String? cnpj;
  final String email;
  final int numero;
  final int cep;
  final String endereco;
  final String bairro;
  final String cidade;
  final String uf;

  Cliente({
    this.id, // Não é mais required
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
    // Validações existentes mantidas
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
    final novoId = idFornecido ?? this.id ?? DateTime.now().millisecondsSinceEpoch;
    
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
      'CEP': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'UF': uf,
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
      cep: json['CEP'] as int,
      endereco: json['endereco'] as String,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      uf: json['UF'] as String,
    ).salvar();
  }

  @override
  String toString() {
    return 'Cliente($id, $nome, $tipo, ${tipo == 'F' ? cpf : cnpj}, $email, $endereco, $numero, $cep, $bairro, $cidade, $uf)';
  }
}