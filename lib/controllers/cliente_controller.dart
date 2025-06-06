import '../database/db_helper.dart';
import '../models/cliente_model.dart';
import '../controllers/buscar_cep.dart';

class ClienteController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ViaCepService _viaCepService = ViaCepService();

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

  

  /// Consulta um CEP na API ViaCep e retorna os dados de endereço
  Future<Map<String, dynamic>> consultarCep(String cep) async {
    try {
      return await _viaCepService.consultarCep(cep);
    } catch (e) {
      throw Exception('Erro ao consultar CEP: ${e.toString()}');
    }
  }

  /// Cria um cliente preenchendo automaticamente o endereço via CEP
  Future<int> adicionarClienteComCep(Cliente cliente, String cep) async {
    try {
      // Consultar dados do CEP
      final dadosCep = await consultarCep(cep);
      

      
      return await adicionarCliente(cliente);
    } catch (e) {
      throw Exception('Erro ao adicionar cliente com CEP: ${e.toString()}');
    }
  }

  /// Atualiza um cliente preenchendo automaticamente o endereço via CEP
  Future<bool> atualizarClienteComCep(Cliente cliente, String cep) async {
    try {
      // Consultar dados do CEP
      final dadosCep = await consultarCep(cep);
      
      // Criar uma nova instância do cliente com os dados do endereço preenchidos
      final clienteComEndereco = Cliente(
        id: cliente.id,
        nome: cliente.nome,
        tipo: cliente.tipo,
        cpfCnpj: cliente.cpfCnpj,
        numero: cliente.numero,
        email: cliente.email,
        // Preencher endereço com dados do ViaCep
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

  /// Busca dados de endereço por CEP (método auxiliar para formulários)
  /// Retorna um Map com os campos formatados para preenchimento automático
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

  /// Valida se um CEP existe na API ViaCep
  Future<bool> validarCep(String cep) async {
    try {
      await consultarCep(cep);
      return true;
    } catch (e) {
      return false;
    }
  }
}