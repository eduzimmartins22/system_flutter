class Produto {
  final int id;
  final String nome;
  final UnidadeProduto unidade;
  final double qtdEstoque;
  final double precoVenda;
  final StatusProduto status;
  final double? custo;
  final String? codigoBarra;
  final DateTime? ultimaAlteracao;
  final int deletado;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.qtdEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
    this.ultimaAlteracao,
    this.deletado = 0,
  });

  Produto copyWith({
    int? id,
    String? nome,
    UnidadeProduto? unidade,
    double? qtdEstoque,
    double? precoVenda,
    StatusProduto? status,
    double? custo,
    String? codigoBarra,
    DateTime? ultimaAlteracao,
    int? deletado,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidade: unidade ?? this.unidade,
      qtdEstoque: qtdEstoque ?? this.qtdEstoque,
      precoVenda: precoVenda ?? this.precoVenda,
      status: status ?? this.status,
      custo: custo ?? this.custo,
      codigoBarra: codigoBarra ?? this.codigoBarra,
      ultimaAlteracao: ultimaAlteracao ?? this.ultimaAlteracao,
      deletado: deletado ?? this.deletado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade.name,
      'codigoBarra': codigoBarra,
      'qtdEstoque': qtdEstoque,
      'custo': custo,
      'precoVenda': precoVenda,
      'Status': status == StatusProduto.ativo ? 0 : 1,
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
      'deletado': deletado,
    }..removeWhere((key, value) => value == null);
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      unidade: UnidadeProduto.values.firstWhere(
        (e) => e.name == json['unidade'],
        orElse: () => UnidadeProduto.Un,
      ),
      qtdEstoque: (json['qtdEstoque'] as num).toDouble(),
      precoVenda: (json['precoVenda'] as num).toDouble(),
      status: json['Status'] == 0 ? StatusProduto.ativo : StatusProduto.inativo,
      custo: (json['custo'] as num?)?.toDouble(),
      codigoBarra: json['codigoBarra'] as String?,
      ultimaAlteracao: json['ultimaAlteracao'] != null
          ? DateTime.parse(json['ultimaAlteracao'] as String)
          : null,
      deletado: json['deletado'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Produto($id, $nome, ${unidade.descricao}, $qtdEstoque, R\$$precoVenda, ${status.descricao})';
  }
}

enum UnidadeProduto {
  Un('Unidade'),
  Cx('Caixa'),
  Kg('Quilograma'),
  Lt('Litro'),
  Ml('Mililitro');

  final String descricao;
  const UnidadeProduto(this.descricao);
}

enum StatusProduto {
  ativo('Ativo'),
  inativo('Inativo');

  final String descricao;
  const StatusProduto(this.descricao);
}