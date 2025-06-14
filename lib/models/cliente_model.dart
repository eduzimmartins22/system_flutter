class Cliente {
  final int id;
  final String nome;
  final TipoCliente tipo;
  final String cpfCnpj;
  final String? email;
  final String? telefone;
  final String? cep;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final DateTime? ultimaAlteracao;
  final int deletado;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
    this.ultimaAlteracao,
    this.deletado = 0,
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
    String? telefone,
    String? cep,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
    DateTime? ultimaAlteracao,
    int? deletado,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      ultimaAlteracao: ultimaAlteracao ?? this.ultimaAlteracao,
      deletado: deletado ?? this.deletado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.sigla,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
      'deletado': deletado,
    };
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int,
      nome: json['nome'] as String,
      tipo: TipoCliente.fromSigla(json['tipo'] as String),
      cpfCnpj: json['cpfCnpj'] as String,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      cep: json['cep'] as String?,
      endereco: json['endereco'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
      ultimaAlteracao: json['ultimaAlteracao'] != null
          ? DateTime.parse(json['ultimaAlteracao'] as String)
          : null,
      deletado: json['deletado'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Cliente($id, $nome, ${tipo.descricao}, $cpfCnpj, $email, $endereco, $telefone, $cep, $bairro, $cidade, $uf)';
  }

  String get cpfCnpjFormatado {
    if (tipo == TipoCliente.fisica && cpfCnpj.length == 11) {
      return '${cpfCnpj.substring(0, 3)}.${cpfCnpj.substring(3, 6)}.${cpfCnpj.substring(6, 9)}-${cpfCnpj.substring(9)}';
    } else if (tipo == TipoCliente.juridica && cpfCnpj.length == 14) {
      return '${cpfCnpj.substring(0, 2)}.${cpfCnpj.substring(2, 5)}.${cpfCnpj.substring(5, 8)}/${cpfCnpj.substring(8, 12)}-${cpfCnpj.substring(12)}';
    } else {
      return cpfCnpj;
    }
  }
}

enum TipoCliente {
  fisica('Pessoa Física', 'F'),
  juridica('Pessoa Jurídica', 'J');

  final String descricao;
  final String sigla;
  const TipoCliente(this.descricao, this.sigla);
  
  static TipoCliente fromSigla(String sigla) {
    return values.firstWhere((e) => e.sigla == sigla);
  }
}