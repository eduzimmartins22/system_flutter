class Usuario {
  final int id;
  final String nome;
  final String senha;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
  }) {
    if (nome.isEmpty) {
      throw ArgumentError('Nome não pode ser vazio');
    }
    
    if (senha.isEmpty) {
      throw ArgumentError('Senha não pode ser vazia');
    }
    
    if (senha.length < 6) {
      throw ArgumentError('Senha deve ter pelo menos 6 caracteres');
    }
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? senha,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      senha: senha ?? this.senha,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      senha: json['senha'] as String,
    );
  }

  @override
  String toString() {
    return 'Usuario($id, $nome)';
  }
}