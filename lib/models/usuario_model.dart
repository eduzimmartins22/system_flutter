class Usuario {
  final int? id;  // Pode ser nulo inicialmente
  final String nome;
  final String senha;

  Usuario({
    this.id,  // Agora é opcional
    required this.nome,
    required this.senha,
  }) {
    // Validações
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

  // Método para salvar que gera um ID se necessário
  Usuario salvar({int? idFornecido}) {
    final novoId = idFornecido ?? this.id ?? DateTime.now().millisecondsSinceEpoch;
    
    return Usuario(
      id: novoId,
      nome: nome,
      senha: senha,
    );
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
    ).salvar();  
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
      id: json['id'] as int?,
      nome: json['nome'] as String,
      senha: json['senha'] as String,
    ).salvar();  
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome)';
  }
}