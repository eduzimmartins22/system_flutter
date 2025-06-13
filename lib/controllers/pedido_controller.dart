import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/pedido_model.dart';

class PedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> criarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // Pedido principal - sem ultimaAlteracao inicialmente
      final pedidoId = await txn.insert('pedidos', {
        'idCliente': pedido.idCliente,
        'idUsuario': pedido.idUsuario,
        'totalPedido': pedido.totalPedido,
        'dataCriacao': DateTime.now().toIso8601String(),
        'ultimaAlteracao': null,
        'deletado': 0,
      });

      // Itens do pedido
      for (final item in pedido.itens) {
        await txn.insert('pedido_itens', {
          'idPedido': pedidoId,
          'idProduto': item.idProduto,
          'quantidade': item.quantidade,
          'totalItem': item.totalItem,
          'ultimaAlteracao': null,
          'deletado': 0,
        });
      }

      // Pagamentos do pedido
      for (final pagamento in pedido.pagamentos) {
        await txn.insert('pedido_pagamentos', {
          'idPedido': pedidoId,
          'valorPagamento': pagamento.valor,
          'ultimaAlteracao': null,
          'deletado': 0,
        });
      }

      return pedidoId;
    });
  }

  Future<List<Pedido>> listarPedidosCompletos() async {
    final db = await _dbHelper.database;
    final pedidos = await db.query(
      'pedidos',
      where: 'deletado = ?',
      whereArgs: [0],
    );
    
    return Future.wait(pedidos.map((pedidoMap) async {
      final itens = await db.query(
        'pedido_itens',
        where: 'idPedido = ? AND deletado = ?',
        whereArgs: [pedidoMap['id'], 0],
      );

      final pagamentos = await db.query(
        'pedido_pagamentos',
        where: 'idPedido = ? AND deletado = ?',
        whereArgs: [pedidoMap['id'], 0],
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

  Future<bool> atualizarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    try {
      await db.transaction((txn) async {
        // Atualiza pedido principal
        await txn.update(
          'pedidos',
          {
            'idCliente': pedido.idCliente,
            'totalPedido': pedido.totalPedido,
            'ultimaAlteracao': pedido.ultimaAlteracao?.toIso8601String() ?? 
                DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [pedido.id],
        );

        // Remove e recria itens
        await txn.delete(
          'pedido_itens',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );

        for (final item in pedido.itens) {
          await txn.insert('pedido_itens', {
            'idPedido': pedido.id,
            'idProduto': item.idProduto,
            'quantidade': item.quantidade,
            'totalItem': item.totalItem,
            'ultimaAlteracao': pedido.ultimaAlteracao?.toIso8601String() ?? 
                DateTime.now().toIso8601String(),
            'deletado': 0,
          });
        }

        // Remove e recria pagamentos
        await txn.delete(
          'pedido_pagamentos',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );

        for (final pagamento in pedido.pagamentos) {
          await txn.insert('pedido_pagamentos', {
            'idPedido': pedido.id,
            'valorPagamento': pagamento.valor,
            'ultimaAlteracao': pedido.ultimaAlteracao?.toIso8601String() ?? 
                DateTime.now().toIso8601String(),
            'deletado': 0,
          });
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removerPedido(int id) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // Marca o pedido e seus relacionamentos como deletados
      final countPedido = await txn.update(
        'pedidos',
        {
          'deletado': 1, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (countPedido == 0) return false;

      await txn.update(
        'pedido_itens',
        {
          'deletado': 1, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      await txn.update(
        'pedido_pagamentos',
        {
          'deletado': 1, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      return true;
    });
  }

  Future<bool> deletarPedido(int id) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // Remove completamente o pedido e seus relacionamentos
      await txn.delete(
        'pedido_pagamentos',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      await txn.delete(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      final count = await txn.delete(
        'pedidos',
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    });
  }

  Future<List<Pedido>> listarPedidosDeletados() async {
    final db = await _dbHelper.database;
    final pedidos = await db.query(
      'pedidos',
      where: 'deletado = ?',
      whereArgs: [1],
    );
    
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

  Future<bool> restaurarPedido(int id) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // Restaura o pedido e seus relacionamentos
      final countPedido = await txn.update(
        'pedidos',
        {
          'deletado': 0, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (countPedido == 0) return false;

      await txn.update(
        'pedido_itens',
        {
          'deletado': 0, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      await txn.update(
        'pedido_pagamentos',
        {
          'deletado': 0, 
          'ultimaAlteracao': DateTime.now().toIso8601String()
        },
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      return true;
    });
  }

  Future<bool> validarPedido(Pedido pedido) async {
    if(pedido.itens.isEmpty || pedido.pagamentos.isEmpty) {
      return false;
    }
    
    // Valida totais
    final totalItens = _calcularTotalItens(pedido.itens);
    final totalPagamentos = _calcularTotalPagamentos(pedido.pagamentos);

    if (totalItens <= 0) {
      return false;
    }
    if (totalPagamentos <= 0) {
      return false;
    }
    if (totalItens != pedido.totalPedido) {
      return false;
    }
    
    return true;
  }

  // Métodos auxiliares simplificados
  double _calcularTotalItens(List<PedidoItem> itens) {
    return itens.fold(0, (sum, item) => sum + item.totalItem);
  }

  double _calcularTotalPagamentos(List<PedidoPagamento> pagamentos) {
    return pagamentos.fold(0, (sum, pag) => sum + pag.valor);
  }
}