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
        'deletado': 0, // Novo pedido não é deletado
      });

      // itens do pedido
      for (final item in pedido.itens) {
        await txn.insert('pedido_itens', {
          'idPedido': pedidoId,
          'idProduto': item.idProduto,
          'quantidade': item.quantidade,
          'totalItem': item.totalItem,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
          'deletado': 0, // Novo item não é deletado
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
          'deletado': 0, // Novo pagamento não é deletado
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
      whereArgs: [0], // 0 = não deletado
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

  Future<bool> removerPedido(int id) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Marca o pedido como deletado
      final countPedido = await txn.update(
        'pedidos',
        {'deletado': 1, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (countPedido == 0) return false;

      // 2. Marca os itens do pedido como deletados
      await txn.update(
        'pedido_itens',
        {'deletado': 1, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 3. Marca os pagamentos do pedido como deletados
      await txn.update(
        'pedido_pagamentos',
        {'deletado': 1, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 4. Devolve os itens ao estoque
      final itens = await txn.query(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      for (final item in itens) {
        await _adicionarAoEstoque(txn, item['idProduto'] as int, item['quantidade'] as double);
      }

      return true;
    });
  }

  Future<bool> deletarPedido(int id) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Remove os pagamentos do pedido
      await txn.delete(
        'pedido_pagamentos',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 2. Remove os itens do pedido
      await txn.delete(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 3. Remove o pedido principal
      final count = await txn.delete(
        'pedidos',
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    });
  }

  Future<bool> atualizarPedidoCompleto(Pedido pedido) async {
    final db = await _dbHelper.database;
    
    try {
      // Primeiro obtém os itens originais para comparar
      final itensOriginais = (await db.query(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [pedido.id],
      )).map((e) => PedidoItem.fromJson(e)).toList();

      // Identifica itens que foram removidos
      final itensRemovidos = itensOriginais.where(
        (original) => !pedido.itens.any((novo) => novo.idProduto == original.idProduto)
      ).toList();

      await db.transaction((txn) async {
        // Devolve ao estoque os itens removidos
        for (final item in itensRemovidos) {
          await _adicionarAoEstoque(txn, item.idProduto, item.quantidade);
        }

        // Resto da lógica de atualização...
        await txn.update(
          'pedidos',
          {
            'idCliente': pedido.idCliente,
            'totalPedido': pedido.totalPedido,
            'ultimaAlteracao': DateTime.now().toIso8601String(),
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
            'ultimaAlteracao': DateTime.now().toIso8601String(),
          });

          await _atualizarEstoqueEmEdicao(txn, item);
        }

        await txn.delete(
          'pedido_pagamentos',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );

        for (final pagamento in pedido.pagamentos) {
          await txn.insert('pedido_pagamentos', {
            'idPedido': pedido.id,
            'valorPagamento': pagamento.valor,
            'ultimaAlteracao': DateTime.now().toIso8601String(),
          });
        }
      });
      return true;
    } catch (e) {
      return false;
    }
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
      
      if (produto.isEmpty || (produto.first['qtdEstoque'] as double) < item.quantidade) {
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

  Future<void> _atualizarEstoque(Transaction txn, int produtoId, double quantidadeVendida) async {
    // Busca produto atual
    final produto = await txn.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [produtoId],
      limit: 1,
    );

    if (produto.isNotEmpty) {
      final estoqueAtual = produto.first['qtdEstoque'] as double;
      final novoEstoque = estoqueAtual - quantidadeVendida;
      
      // Atualiza estoque
      await txn.update(
        'produtos',
        {
          'qtdEstoque': novoEstoque,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [produtoId],
      );
    }
  }

  Future<void> _atualizarEstoqueEmEdicao(Transaction txn, PedidoItem novoItem) async {
    final itensOriginais = await txn.query(
      'pedido_itens',
      where: 'idPedido = ? AND idProduto = ?',
      whereArgs: [novoItem.idPedido, novoItem.idProduto],
    );

    int quantidadeOriginal = 0;
    if (itensOriginais.isNotEmpty) {
      quantidadeOriginal = itensOriginais.first['quantidade'] as int;
    }

    final diferencaQuantidade = quantidadeOriginal - novoItem.quantidade;

    if (diferencaQuantidade != 0) {
      final produto = await txn.query(
        'produtos',
        where: 'id = ?',
        whereArgs: [novoItem.idProduto],
        limit: 1,
      );

      if (produto.isNotEmpty) {
        final estoqueAtual = produto.first['qtdEstoque'] as double;
        final novoEstoque = estoqueAtual + diferencaQuantidade;
        
        await txn.update(
          'produtos',
          {
            'qtdEstoque': novoEstoque,
            'ultimaAlteracao': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [novoItem.idProduto],
        );
      }
    }
  }

  Future<void> devolverItensAoEstoque(List<PedidoItem> itensRemovidos) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (final item in itensRemovidos) {
        await _adicionarAoEstoque(txn, item.idProduto, item.quantidade);
      }
    });
  }

  Future<void> _adicionarAoEstoque(Transaction txn, int produtoId, double quantidade) async {
    final produto = await txn.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [produtoId],
      limit: 1,
    );

    if (produto.isNotEmpty) {
      final estoqueAtual = produto.first['qtdEstoque'] as double;
      await txn.update(
        'produtos',
        {
          'qtdEstoque': estoqueAtual + quantidade,
          'ultimaAlteracao': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [produtoId],
      );
    }
  }

  Future<List<Pedido>> listarPedidosDeletados() async {
    final db = await _dbHelper.database;
    final pedidos = await db.query(
      'pedidos',
      where: 'deletado = ?',
      whereArgs: [1], // 1 = deletado
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
      // 1. Restaura o pedido principal
      final countPedido = await txn.update(
        'pedidos',
        {'deletado': 0, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (countPedido == 0) return false;

      // 2. Restaura os itens do pedido
      await txn.update(
        'pedido_itens',
        {'deletado': 0, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 3. Restaura os pagamentos do pedido
      await txn.update(
        'pedido_pagamentos',
        {'deletado': 0, 'ultimaAlteracao': DateTime.now().toIso8601String()},
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      // 4. Remove os itens do estoque (inverso do que foi feito no soft delete)
      final itens = await txn.query(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [id],
      );

      for (final item in itens) {
        await _atualizarEstoque(txn, item['idProduto'] as int, item['quantidade'] as double);
      }

      return true;
    });
  }
}