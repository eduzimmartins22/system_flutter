class Usuario {
  final int id;
  final String nome;
  final String senha;
  final DateTime? ultimaAlteracao;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
    this.ultimaAlteracao,
  }) {
    if (nome.isEmpty) {
      throw ArgumentError('Nome não pode ser vazio');
    }
    
    if (senha.isEmpty) {
      throw ArgumentError('Senha não pode ser vazia');
    }
    
    if (senha.length < 6 && nome != 'admin') {
      throw ArgumentError('Senha deve ter pelo menos 6 caracteres');
    }
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? senha,
    DateTime? ultimaAlteracao,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      senha: senha ?? this.senha,
      ultimaAlteracao: ultimaAlteracao ?? this.ultimaAlteracao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
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
    );
  }

  @override
  String toString() {
    return 'Usuario($id, $nome)';
  }
}