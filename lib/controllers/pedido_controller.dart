import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/pedido_model.dart';

class PedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> criarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // pedido principal
      final pedidoId = await txn.insert('pedidos', {
        'idCliente': pedido.idCliente,
        'idUsuario': pedido.idUsuario,
        'totalPedido': pedido.totalPedido,
        'dataCriacao': DateTime.now().toIso8601String(),
        'ultimaAlteracao': DateTime.now().toIso8601String(),
      });

      // itens do pedido
      for (final item in pedido.itens) {
        await txn.insert('pedido_itens', {
          'idPedido': pedidoId,
          'idProduto': item.idProduto,
          'quantidade': item.quantidade,
          'totalItem': item.totalItem,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
        });

        // atualiza estoque do produto
        await _atualizarEstoque(txn, item.idProduto, item.quantidade);
      }

      // pagamentos do pedido
      for (final pagamento in pedido.pagamentos) {
        await txn.insert('pedido_pagamentos', {
          'idPedido': pedidoId,
          'valorPagamento': pagamento.valor,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
        });
      }

      return pedidoId;
    });
  }

  Future<List<Pedido>> listarPedidosCompletos() async {
    final db = await _dbHelper.database;
    final pedidos = await db.query('pedidos');
    
    return Future.wait(pedidos.map((pedidoMap) async {
      final itens = await db.query(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [pedidoMap['id']],
      );

      final pagamentos = await db.query(
        'pedido_pagamentos',
        where: 'idPedido = ?',
        whereArgs: [pedidoMap['id']],
      );

      return Pedido(
        id: pedidoMap['id'] as int,
        idCliente: pedidoMap['idCliente'] as int,
        idUsuario: pedidoMap['idUsuario'] as int,
        totalPedido: (pedidoMap['totalPedido'] as num).toDouble(),
        dataCriacao: DateTime.parse(pedidoMap['dataCriacao'] as String),
        ultimaAlteracao: pedidoMap['ultimaAlteracao'] != null 
            ? DateTime.parse(pedidoMap['ultimaAlteracao'] as String) 
            : null,
        itens: itens.map((item) => PedidoItem.fromJson(item)).toList(),
        pagamentos: pagamentos.map((pag) => PedidoPagamento.fromJson(pag)).toList(),
      );
    }));
  }

  Future<bool> validarPedido(Pedido pedido) async {
    if (pedido.itens.isEmpty || pedido.pagamentos.isEmpty) {
      return false;
    }

    final totalItens = _calcularTotalItens(pedido.itens);
    final totalPagamentos = _calcularTotalPagamentos(pedido.pagamentos);

    final db = await _dbHelper.database;
    for (final item in pedido.itens) {
      final produto = await db.query(
        'produtos',
        where: 'id = ?',
        whereArgs: [item.idProduto],
        limit: 1,
      );
      
      if (produto.isEmpty || (produto.first['quantidadeEstoque'] as int) < item.quantidade) {
        return false;
      }
    }

    return (totalItens - totalPagamentos).abs() < 0.01;
  }

  double _calcularTotalItens(List<PedidoItem> itens) {
    return itens.fold(0, (sum, item) => sum + item.totalItem);
  }

  double _calcularTotalPagamentos(List<PedidoPagamento> pagamentos) {
    return pagamentos.fold(0, (sum, pag) => sum + pag.valor);
  }

  Future<void> _atualizarEstoque(Transaction txn, int produtoId, int quantidadeVendida) async {
    // Busca produto atual
    final produto = await txn.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [produtoId],
      limit: 1,
    );

    if (produto.isNotEmpty) {
      final estoqueAtual = produto.first['quantidadeEstoque'] as int;
      final novoEstoque = estoqueAtual - quantidadeVendida;
      
      // Atualiza estoque
      await txn.update(
        'produtos',
        {
          'quantidadeEstoque': novoEstoque,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [produtoId],
      );
    }
  }
}