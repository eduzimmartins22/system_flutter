class Usuario {
  final int id;
  final String nome;
  final String senha;
  late final DateTime? ultimaAlteracao;
  final int deletado;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
    this.ultimaAlteracao,
    this.deletado = 0,

  }) {
    if (nome.isEmpty) {
      throw ArgumentError('Nome não pode ser vazio');
    }
    
    if (senha.isEmpty) {
      throw ArgumentError('Senha não pode ser vazia');
    }
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? senha,
    DateTime? ultimaAlteracao,
    int? deletado,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      senha: senha ?? this.senha,
      ultimaAlteracao: ultimaAlteracao ?? this.ultimaAlteracao,
      deletado: deletado ?? this.deletado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
      'deletado': deletado,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      senha: json['senha'] as String,
      ultimaAlteracao: json['ultimaAlteracao'] != null
          ? DateTime.parse(json['ultimaAlteracao'] as String)
          : null,
      deletado: json['deletado'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Usuario($id, $nome)';
  }
}