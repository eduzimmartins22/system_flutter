import '../database/db_helper.dart';
import '../models/produto_model.dart';

class ProdutoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Produto>> getProdutos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'produtos',
      where: 'deletado = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Produto.fromJson(map)).toList();
  }

  Future<List<Produto>> buscarProdutosAtivos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'produtos',
      where: 'Status = ? AND deletado = ?',
      whereArgs: [1, 0],
    );
    return maps.map((map) => Produto.fromJson(map)).toList();
  }

  Future<Produto?> getProdutoPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Produto.fromJson(maps.first);
    }
    return null;
  }

  Future<int> adicionarProduto(Produto produto) async {
    final db = await _dbHelper.database;
    final map = produto.toJson();
      map.remove('id');
      map['deletado'] = 0;
    return await db.insert('produtos', map);
  }

  Future<bool> atualizarProduto(Produto produto) async {
    final db = await _dbHelper.database;

    final count = await db.update(
      'produtos',
      produto.toJson(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
    return count > 0;
  }

  Future<bool> removerProduto(int id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'produtos',
      {'deletado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> deletarProduto(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<int> contarProdutos() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM produtos WHERE deletado = ?',
      [0]
    );
    return result.first['count'] as int;
  }

  Future<List<Produto>> getProdutosDeletados() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'produtos',
      where: 'deletado = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Produto.fromJson(map)).toList();
  }

  Future<bool> restaurarProduto(int id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'produtos',
      {'deletado': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<List<Produto>> getProdutosComAlteracoes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'ultimaAlteracao IS NOT NULL',
    );
    return List.generate(maps.length, (i) => Produto.fromJson(maps[i]));
  }

  Future<void> atualizarDataAlteracao(int id, String ultimaAlteracao) async {
    final db = await _dbHelper.database;
    await db.update(
      'produtos',
      {'ultimaAlteracao': ultimaAlteracao},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertProdutoFromServer(Produto produto) async {
    final db = await _dbHelper.database;
    final existing = await getProdutoPorId(produto.id);
    
    if (existing != null) {
      await db.update(
        'produtos',
        produto.toJson(),
        where: 'id = ?',
        whereArgs: [produto.id],
      );
    } else {
      await db.insert('produtos', produto.toJson());
    }
  }
  
}