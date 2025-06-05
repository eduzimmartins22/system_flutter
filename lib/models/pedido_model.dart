class Pedido {
  final int id;
  final int idCliente;
  final int idUsuario;
  final double totalPedido;
  final DateTime dataCriacao;
  final DateTime? ultimaAlteracao;
  final List<PedidoItem> itens;
  final List<PedidoPagamento> pagamentos;

  Pedido({
    required this.id,
    required this.idCliente,
    required this.idUsuario,
    required this.totalPedido,
    required this.dataCriacao,
    this.ultimaAlteracao,
    required this.itens,
    required this.pagamentos,
  });

  Pedido copyWith({
    int? id,
    int? idCliente,
    int? idUsuario,
    double? totalPedido,
    DateTime? dataCriacao,
    List<PedidoItem>? itens,
    List<PedidoPagamento>? pagamentos,
  }) {
    return Pedido(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      idUsuario: idUsuario ?? this.idUsuario,
      totalPedido: totalPedido ?? this.totalPedido,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      itens: itens ?? this.itens,
      pagamentos: pagamentos ?? this.pagamentos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idCliente': idCliente,
      'idUsuario': idUsuario,
      'totalPedido': totalPedido,
      'dataCriacao': dataCriacao.toIso8601String(),
      'ultimaAlteracao': ultimaAlteracao?.toIso8601String(),
      'itens': itens.map((item) => item.toJson()).toList(),
      'pagamentos': pagamentos.map((pag) => pag.toJson()).toList(),
    };
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int,
      idCliente: json['idCliente'] as int,
      idUsuario: json['idUsuario'] as int,
      totalPedido: (json['totalPedido'] as num).toDouble(),
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      ultimaAlteracao: json['ultimaAlteracao'] != null 
          ? DateTime.parse(json['ultimaAlteracao'] as String) 
          : null,
      itens: (json['itens'] as List<dynamic>)
          .map((item) => PedidoItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagamentos: (json['pagamentos'] as List<dynamic>)
          .map((pag) => PedidoPagamento.fromJson(pag as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PedidoItem {
  final int id;
  final int idPedido;
  final int idProduto;
  final int quantidade;
  final double totalItem;

  PedidoItem({
    required this.id,
    required this.idPedido,
    required this.idProduto,
    required this.quantidade,
    required this.totalItem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': idPedido,
      'idProduto': idProduto,
      'quantidade': quantidade,
      'totalItem': totalItem,
    };
  }

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      id: json['id'] as int,
      idPedido: json['idPedido'] as int,
      idProduto: json['idProduto'] as int,
      quantidade: json['quantidade'] as int,
      totalItem: (json['totalItem'] as num).toDouble(),
    );
  }
}

class PedidoPagamento {
  final int id;
  final int idPedido;
  final double valor;

  PedidoPagamento({
    required this.id,
    required this.idPedido,
    required this.valor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': idPedido,
      'valorPagamento': valor,
    };
  }

  factory PedidoPagamento.fromJson(Map<String, dynamic> json) {
    return PedidoPagamento(
      id: json['id'] as int,
      idPedido: json['idPedido'] as int,
      valor: (json['valorPagamento'] as num).toDouble(),
    );
  }
}