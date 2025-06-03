class Cliente {
  final int? id;
  final String nome;
  final String email;
  final String? telefone;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? cep;
  final String cpfCnpj;
  final DateTime? dataCadastro;
  final bool ativo;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
    required this.cpfCnpj,
    this.dataCadastro,
    this.ativo = true,
  });

  // Converter de JSON para objeto Cliente
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      endereco: json['endereco'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      uf: json['uf'],
      cep: json['cep'],
      cpfCnpj: json['cpfCnpj'] ?? json['cpf_cnpj'] ?? '',
      dataCadastro: json['dataCadastro'] != null || json['data_cadastro'] != null
          ? DateTime.parse(json['dataCadastro'] ?? json['data_cadastro']) 
          : null,
      ativo: json['ativo'] ?? true,
    );
  }

  // Converter objeto Cliente para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'cep': cep,
      'cpfCnpj': cpfCnpj,
      'dataCadastro': dataCadastro?.toIso8601String(),
      'ativo': ativo,
    };
  }

  // Método para compatibilidade com seu código existente (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'cep': cep,
      'cpfCnpj': cpfCnpj,
      'dataCadastro': dataCadastro?.millisecondsSinceEpoch,
      'ativo': ativo ? 1 : 0,
    };
  }

  // Factory para compatibilidade com SQLite
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      endereco: map['endereco'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      uf: map['uf'],
      cep: map['cep'],
      cpfCnpj: map['cpfCnpj'] ?? '',
      dataCadastro: map['dataCadastro'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dataCadastro'])
          : null,
      ativo: map['ativo'] == 1,
    );
  }

  // Método para criar cópia com alterações
  Cliente copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
    String? cep,
    String? cpfCnpj,
    DateTime? dataCadastro,
    bool? ativo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      cep: cep ?? this.cep,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ativo: ativo ?? this.ativo,
    );
  }

  // Getters para facilitar uso
  String get nomeCompleto => nome;
  String get documento => cpfCnpj;
  
  String get enderecoCompleto {
    final partes = <String>[];
    if (endereco != null && endereco!.isNotEmpty) partes.add(endereco!);
    if (bairro != null && bairro!.isNotEmpty) partes.add(bairro!);
    if (cidade != null && cidade!.isNotEmpty) partes.add(cidade!);
    if (uf != null && uf!.isNotEmpty) partes.add(uf!);
    return partes.join(', ');
  }

  // Validações
  bool get isEmailValido {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool get isCpfValido {
    if (cpfCnpj.length == 11) {
      // Validação básica de CPF
      return RegExp(r'^\d{11}$').hasMatch(cpfCnpj);
    }
    return false;
  }

  bool get isCnpjValido {
    if (cpfCnpj.length == 14) {
      // Validação básica de CNPJ
      return RegExp(r'^\d{14}$').hasMatch(cpfCnpj);
    }
    return false;
  }

  bool get isDocumentoValido => isCpfValido || isCnpjValido;

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, email: $email, cpfCnpj: $cpfCnpj}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cliente &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cpfCnpj == other.cpfCnpj;

  @override
  int get hashCode => id.hashCode ^ cpfCnpj.hashCode;
}