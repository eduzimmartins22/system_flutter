import '../database/db_helper.dart';
import '../models/pedido_model.dart';

class PedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> criarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      final pedidoId = await txn.insert('pedidos', {
        'idCliente': pedido.idCliente,
        'idUsuario': pedido.idUsuario,
        'totalPedido': pedido.totalPedido,
        'dataCriacao': DateTime.now().toIso8601String(),
        'ultimaAlteracao': null,
        'deletado': 0,
      });

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

      for (final pagamento in pedido.pagamentos) {
        await txn.insert('pedido_pagamentos', {
          'idPedido': pedidoId,
          'valor': pagamento.valor,
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

  Future<Pedido?> getPedidoById(int id) async {
    final db = await _dbHelper.database;

    final pedidoResult = await db.query(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (pedidoResult.isEmpty) return null;

    final itensResult = await db.query(
      'pedido_itens',
      where: 'idPedido = ?',
      whereArgs: [id],
    );

    final pagamentosResult = await db.query(
      'pedido_pagamentos',
      where: 'idPedido = ?',
      whereArgs: [id],
    );

    final pedidoData = pedidoResult.first;
    
    final itens = itensResult.map((item) => PedidoItem(
      id: item['id'] as int,
      idPedido: item['idPedido'] as int,
      idProduto: item['idProduto'] as int,
      quantidade: (item['quantidade'] as num).toDouble(),
      totalItem: (item['totalItem'] as num).toDouble(),
    )).toList();

    final pagamentos = pagamentosResult.map((pagamento) => PedidoPagamento(
      id: pagamento['id'] as int,
      idPedido: pagamento['idPedido'] as int,
      valor: (pagamento['valor'] as num).toDouble(),
    )).toList();

    // 5. Construir e retornar o objeto Pedido completo
    return Pedido(
      id: pedidoData['id'] as int,
      idCliente: pedidoData['idCliente'] as int,
      idUsuario: pedidoData['idUsuario'] as int,
      totalPedido: (pedidoData['totalPedido'] as num).toDouble(),
      dataCriacao: DateTime.parse(pedidoData['dataCriacao'] as String),
      ultimaAlteracao: pedidoData['ultimaAlteracao'] != null 
          ? DateTime.parse(pedidoData['ultimaAlteracao'] as String) 
          : null,
      deletado: pedidoData['deletado'] as int? ?? 0,
      itens: itens,
      pagamentos: pagamentos,
    );
  }

  Future<bool> atualizarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    try {
      await db.transaction((txn) async {
        await txn.update(
          'pedidos',
          {
            'idCliente': pedido.idCliente,
            'totalPedido': pedido.totalPedido,
            'ultimaAlteracao': pedido.ultimaAlteracao != null ? DateTime.now().toIso8601String() : null,
          },
          where: 'id = ?',
          whereArgs: [pedido.id],
        );

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
            'deletado': 0,
          });
        }

        await txn.delete(
          'pedido_pagamentos',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );

        for (final pagamento in pedido.pagamentos) {
          await txn.insert('pedido_pagamentos', {
            'idPedido': pedido.id,
            'valor': pagamento.valor,
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

  Future<void> upsertPedidoFromServer(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      final existing = await txn.query(
        'pedidos',
        where: 'id = ?',
        whereArgs: [pedido.id],
        limit: 1,
      );

      final pedidoJson = pedido.toDbJson();

      if (existing.isNotEmpty) {
        await txn.update(
          'pedidos',
          pedidoJson,
          where: 'id = ?',
          whereArgs: [pedido.id],
        );
        
        await txn.delete(
          'pedido_itens',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
        await txn.delete(
          'pedido_pagamentos',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
      } else {
        await txn.insert('pedidos', pedidoJson);
      }

      for (final item in pedido.itens) {
        await txn.insert('pedido_itens', item.toJson());
      }

      for (final pagamento in pedido.pagamentos) {
        await txn.insert('pedido_pagamentos', pagamento.toJson());
      }
    });
  }

  Map<String, dynamic> formatarParaServidor(Pedido pedido) {
    return {
      'id': pedido.id,
      'idCliente': pedido.idCliente,
      'idUsuario': pedido.idUsuario,
      'totalPedido': pedido.totalPedido,
      'dataCriacao': _formatarData(pedido.dataCriacao),
      'ultimaAlteracao': _formatarData(pedido.ultimaAlteracao),
      'itens': pedido.itens?.map((item) => {
        'id': item.id,
        'idPedido': item.idPedido,
        'idProduto': item.idProduto,
        'quantidade': item.quantidade,
        'totalItem': item.totalItem,
      }).toList(),
      'pagamentos': pedido.pagamentos?.map((pagamento) => {
        'id': pagamento.id,
        'idPedido': pagamento.idPedido,
        'valor': pagamento.valor,
      }).toList(),
    };
  }

  // métodos auxiliares simplificados
  double _calcularTotalItens(List<PedidoItem> itens) {
    return itens.fold(0, (sum, item) => sum + item.totalItem);
  }

  double _calcularTotalPagamentos(List<PedidoPagamento> pagamentos) {
    return pagamentos.fold(0, (sum, pag) => sum + pag.valor);
  }

  String? _formatarData(DateTime? date) {
    return date?.toUtc().toIso8601String();
  }
}