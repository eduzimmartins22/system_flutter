import '../database/db_helper.dart';
import '../models/cliente_model.dart';

class ClienteController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Cliente>> getClientes() async {
    final db = await _dbHelper.database;
    final maps = await db.query('clientes');
    return maps.map((map) => Cliente.fromJson(map)).toList();
  }

  Future<int> adicionarCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    
    final existe = await documentoExiste(cliente.cpfCnpj);
    if (existe) {
      throw Exception('Já existe um cliente com este documento');
    }
    
    final map = cliente.toJson();
    map.remove('id');
    
    return await db.insert('clientes', map);
  }

  Future<bool> atualizarCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    
    final clientesComMesmoDoc = await db.query(
      'clientes',
      where: 'cpfCnpj = ? AND id <> ?',
      whereArgs: [cliente.cpfCnpj, cliente.id],
    );
    
    if (clientesComMesmoDoc.isNotEmpty) {
      throw Exception('Já existe um cliente com este documento');
    }
    
    final count = await db.update(
      'clientes',
      cliente.toJson(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
    return count > 0;
  }

  Future<bool> removerCliente(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<Cliente?> buscarPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Cliente.fromJson(maps.first);
    }
    return null;
  }

  Future<Cliente?> buscarPorDocumento(String documento) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clientes',
      where: 'cpfCnpj = ?',
      whereArgs: [documento],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Cliente.fromJson(maps.first);
    }
    return null;
  }

  Future<bool> documentoExiste(String documento, [int? idExcluir]) async {
    final db = await _dbHelper.database;
    final where = idExcluir != null 
        ? 'cpfCnpj = ? AND id <> ?' 
        : 'cpfCnpj = ?';
    final whereArgs = idExcluir != null 
        ? [documento, idExcluir] 
        : [documento];
    
    final maps = await db.query(
      'clientes',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }
}