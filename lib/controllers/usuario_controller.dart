import '../database/db_helper.dart';
import '../models/usuario_model.dart';

class UsuarioController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Usuario>> getUsuarios() async {
    final db = await _dbHelper.database;
    final maps = await db.query('usuarios');
    return maps.map((map) => Usuario.fromJson(map)).toList();
  }

  Future<int> adicionarUsuario(Usuario usuario) async {
    final db = await _dbHelper.database;
    
    final existe = await nomeUsuarioExiste(usuario.nome);
    if (existe) {
      throw Exception('Já existe um usuário com este nome');
    }
    final map = usuario.toJson();
    map.remove('id');
    return await db.insert('usuarios', map);
  }

  Future<bool> atualizarUsuario(Usuario usuario) async {
    final db = await _dbHelper.database;
    
    final usuariosComMesmoNome = await db.query(
      'usuarios',
      where: 'nome = ? AND id <> ?',
      whereArgs: [usuario.nome, usuario.id],
    );
    
    if (usuariosComMesmoNome.isNotEmpty) {
      throw Exception('Já existe um usuário com este nome');
    }
    
    final count = await db.update(
      'usuarios',
      usuario.toJson(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
    return count > 0;
  }

  Future<bool> removerUsuario(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Usuario.fromJson(maps.first);
    }
    return null;
  }

  Future<Usuario?> buscarPorNomeESenha(String nome, String senha) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'nome = ? AND senha = ?',
      whereArgs: [nome, senha],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Usuario.fromJson(maps.first);
    }
    return null;
  }

  Future<bool> nomeUsuarioExiste(String nome) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'nome = ?',
      whereArgs: [nome],
    );
    return maps.isNotEmpty;
  }
}