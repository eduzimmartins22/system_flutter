import '../database/db_helper.dart';
import '../models/usuario_model.dart';

class UsuarioController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  Future<List<Usuario>> getUsuarios() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'deletado = ?',
      whereArgs: [0],
    );
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
    map['deletado'] = 0;
    return await db.insert('usuarios', map);
  }

  Future<bool> atualizarUsuario(Usuario usuario) async {
    final db = await _dbHelper.database;
    
    final usuariosComMesmoNome = await db.query(
      'usuarios',
      where: 'nome = ? AND id <> ? AND deletado = ?',
      whereArgs: [usuario.nome, usuario.id, 0],
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
    final count = await db.update(
      'usuarios',
      {'deletado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> deletarUsuario(int id) async {
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
      where: 'nome = ? AND senha = ? AND deletado = ?',
      whereArgs: [nome, senha, 0],
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
      where: 'nome = ? AND deletado = ?',
      whereArgs: [nome, 0],
    );
    return maps.isNotEmpty;
  }

  Future<List<Usuario>> getUsuariosDeletados() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'deletado = ?',
      whereArgs: [1], // 1 = deletado
    );
    return maps.map((map) => Usuario.fromJson(map)).toList();
  }

  Future<bool> restaurarUsuario(int id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'usuarios',
      {'deletado': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<List<Usuario>> getUsuariosNaoSincronizados() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'deletado = ? AND (ultimaAlteracao IS NULL OR id NOT IN '
             '(SELECT id FROM usuarios WHERE ultimaAlteracao IS NOT NULL))',
      whereArgs: [0],
    );
    return maps.map((map) => Usuario.fromJson(map)).toList();
  }

  Future<void> upsertUsuarioFromServer(Usuario usuario) async {
    final db = await _dbHelper.database;
    final existing = await buscarPorId(usuario.id);
    
    if (existing != null) {
      await db.update(
        'usuarios',
        usuario.toJson(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
    } else {
      await db.insert('usuarios', usuario.toJson());
    }
  }

  Future<void> atualizarDataAlteracao(int id, String ultimaAlteracao) async {
    final db = await _dbHelper.database;
    await db.update(
      'usuarios',
      {'ultimaAlteracao': ultimaAlteracao},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Usuario>> getUsuariosComAlteracoes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'ultimaAlteracao IS NOT NULL',
    );
    return List.generate(maps.length, (i) => Usuario.fromJson(maps[i]));
  }
}