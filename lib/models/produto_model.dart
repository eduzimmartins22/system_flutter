class Produto {
  final int id;
  final String nome;
  final UnidadeProduto unidade;
  final int quantidadeEstoque;
  final double precoVenda;
  final StatusProduto status;
  final double? precoCusto;
  final String? codigoBarras;
  final DateTime? ultimaAlteracao;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeEstoque,
    required this.precoVenda,
    required this.status,
    this.precoCusto,
    this.codigoBarras,
    this.ultimaAlteracao,
  });

  Produto copyWith({
    int? id,
    String? nome,
    UnidadeProduto? unidade,
    int? quantidadeEstoque,
    double? precoVenda,
    StatusProduto? status,
    double? precoCusto,
    String? codigoBarras,
    DateTime? ultimaAlteracao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidade: unidade ?? this.unidade,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      precoVenda: precoVenda ?? this.precoVenda,
      status: status ?? this.status,
      precoCusto: precoCusto ?? this.precoCusto,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      ultimaAlteracao: ultimaAlteracao ?? this.ultimaAlteracao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade.name,
      'quantidadeEstoque': quantidadeEstoque,
      'precoVenda': precoVenda,
      'status': status.name,
      'precoCusto': precoCusto,
      'codigoBarras': codigoBarras,
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      unidade: UnidadeProduto.values.byName(json['unidade'] as String),
      quantidadeEstoque: json['quantidadeEstoque'] as int,
      precoVenda: (json['precoVenda'] as num).toDouble(),
      status: StatusProduto.values.byName(json['status'] as String),
      precoCusto: json['precoCusto'] as double?,
      codigoBarras: json['codigoBarras'] as String?,
      ultimaAlteracao: json['ultimaAlteracao'] != null
          ? DateTime.parse(json['ultimaAlteracao'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Produto($id, $nome, ${unidade.descricao}, $quantidadeEstoque, R\$$precoVenda, ${status.descricao})';
  }
}

enum UnidadeProduto {
  un('Unidade'),
  cx('Caixa'),
  kg('Quilograma'),
  lt('Litro'),
  ml('Mililitro');

  final String descricao;
  const UnidadeProduto(this.descricao);
}

enum StatusProduto {
  ativo('Ativo'),
  inativo('Inativo');

  final String descricao;
  const StatusProduto(this.descricao);
}