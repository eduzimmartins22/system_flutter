import '../database/db_helper.dart';
import '../models/cliente_model.dart';
import '../controllers/buscar_cep.dart';

class ClienteController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ViaCepService _viaCepService = ViaCepService();

  Future<List<Cliente>> getClientes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clientes',
      where: 'deletado = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Cliente.fromJson(map)).toList();
  }

  Future<int> adicionarCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    
    final existe = await documentoExiste(cliente.cpfCnpj);
    if (existe) {
      throw Exception('Já existe um cliente com este documento');
    }
    
    final map = cliente.toJson()
      ..remove('id')
      ..['deletado'] = 0;
    
    return await db.insert('clientes', map);
  }

  Future<bool> atualizarCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    
    final clientesComMesmoDoc = await db.query(
      'clientes',
      where: 'cpfCnpj = ? AND id <> ? AND deletado = ?',
      whereArgs: [cliente.cpfCnpj, cliente.id, 0],
    );
    
    if (clientesComMesmoDoc.isNotEmpty) {
      throw Exception('Já existe um cliente com este documento');
    }
    
    final count = await db.update(
      'clientes',
      cliente.toJson(),
      where: 'id = ? AND deletado = ?',
      whereArgs: [cliente.id, 0],
    );
    return count > 0;
  }

  Future<bool> removerCliente(int id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'clientes',
      {'deletado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> deletarCliente(int id) async {
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
      where: 'id = ? AND deletado = ?',
      whereArgs: [id, 0],
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
      where: 'cpfCnpj = ? AND deletado = ?',
      whereArgs: [documento, 0],
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
        ? 'cpfCnpj = ? AND id <> ? AND deletado = ?' 
        : 'cpfCnpj = ? AND deletado = ?';
    final whereArgs = idExcluir != null 
        ? [documento, idExcluir, 0] 
        : [documento, 0];
    
    final maps = await db.query(
      'clientes',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }

  Future<List<Cliente>> getClientesDeletados() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clientes',
      where: 'deletado = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Cliente.fromJson(map)).toList();
  }

  Future<bool> restaurarCliente(int id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'clientes',
      {'deletado': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<int> contarClientes() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM clientes WHERE deletado = ?',
      [0]
    );
    return result.first['count'] as int;
  }

  Future<Map<String, dynamic>> consultarCep(String cep) async {
    try {
      return await _viaCepService.consultarCep(cep);
    } catch (e) {
      throw Exception('Erro ao consultar CEP: ${e.toString()}');
    }
  }

  Future<int> adicionarClienteComCep(Cliente cliente, String cep) async {
    try {
      final dadosCep = await consultarCep(cep);
      return await adicionarCliente(cliente);
    } catch (e) {
      throw Exception('Erro ao adicionar cliente com CEP: ${e.toString()}');
    }
  }

  Future<bool> atualizarClienteComCep(Cliente cliente, String cep) async {
    try {
      final dadosCep = await consultarCep(cep);
      
      final clienteComEndereco = Cliente(
        id: cliente.id,
        nome: cliente.nome,
        tipo: cliente.tipo,
        cpfCnpj: cliente.cpfCnpj,
        telefone: cliente.telefone,
        email: cliente.email,
        endereco: dadosCep['logradouro'] ?? cliente.endereco,
        cidade: dadosCep['localidade'] ?? cliente.cidade,
        uf: dadosCep['uf'] ?? cliente.uf,
        cep: dadosCep['cep'] ?? cep,
        bairro: dadosCep['bairro'] ?? cliente.bairro,
        ultimaAlteracao: DateTime.now(),
      );
      
      return await atualizarCliente(clienteComEndereco);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente com CEP: ${e.toString()}');
    }
  }

  Future<Map<String, String>> buscarEnderecoPorCep(String cep) async {
    try {
      final dadosCep = await consultarCep(cep);
      
      return {
        'logradouro': dadosCep['logradouro'] ?? '',
        'bairro': dadosCep['bairro'] ?? '',
        'cidade': dadosCep['localidade'] ?? '',
        'estado': dadosCep['uf'] ?? '',
        'cep': dadosCep['cep'] ?? cep,
        'complemento': dadosCep['complemento'] ?? '',
      };
    } catch (e) {
      throw Exception('Erro ao buscar endereço: ${e.toString()}');
    }
  }

  Future<bool> validarCep(String cep) async {
    try {
      await consultarCep(cep);
      return true;
    } catch (e) {
      return false;
    }
  }
}