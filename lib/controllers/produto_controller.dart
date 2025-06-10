import '../database/db_helper.dart';
import '../models/produto_model.dart';

class ProdutoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Produto>> getProdutos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('produtos');
    return maps.map((map) => Produto.fromJson(map)).toList();
  }

  Future<List<Produto>> buscarProdutosAtivos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'produtos',
      where: 'Status = ?',
      whereArgs: [1],
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
    final map = produto.toJson()..remove('id');
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
    final count = await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<int> contarProdutos() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM produtos');
    return result.first['count'] as int;
  }
}