import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if(_database == null) {
      String path = await getDatabasesPath();
      path = join(path, 'db_app-vendas.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreateDB,
        onUpgrade: _onUpgradeDB,
      ); 
    }
    return _database!;
  }

  Future<void> _onCreateDB(Database db, version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  Future<void> _createTables(Database db) async {
    //usuario
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL,
        ultimaAlteracao TEXT,
        CONSTRAINT usuario_nome_unico UNIQUE (nome)
      )
    ''');

    //produto
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        unidade TEXT NOT NULL CHECK (unidade IN ('un', 'cx', 'kg', 'lt', 'ml')),
        quantidadeEstoque INTEGER NOT NULL DEFAULT 0,
        precoVenda REAL NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('ativo', 'inativo')),
        precoCusto REAL,
        codigoBarras TEXT,
        ultimaAlteracao TEXT,
        CONSTRAINT preco_venda_positivo CHECK (precoVenda >= 0),
        CONSTRAINT estoque_positivo CHECK (quantidadeEstoque >= 0),
        CONSTRAINT produto_nome_unico UNIQUE (nome)
      )
    ''');

    //cliente
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK (tipo IN ('fisica', 'juridica')),
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        numero INTEGER,
        cep TEXT,  -- Alterado para TEXT pois no modelo pode ser null e em alguns casos pode conter hífen
        endereco TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        ultimaAlteracao TEXT,
        CONSTRAINT cpf_cnpj_unico UNIQUE (cpfCnpj),
        CONSTRAINT cpf_length CHECK (
          (tipo = 'fisica' AND LENGTH(cpfCnpj) = 11) OR
          (tipo = 'juridica' AND LENGTH(cpfCnpj) = 14)
        )
      )
    ''');

    //pedido
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCliente INTEGER NOT NULL,
        idUsuario INTEGER NOT NULL,
        totalPedido REAL NOT NULL,
        dataCriacao TEXT NOT NULL,
        ultimaAlteracao TEXT,
        FOREIGN KEY (idCliente) REFERENCES clientes(id),
        FOREIGN KEY (idUsuario) REFERENCES usuarios(id)
      )
    ''');

    //pedido_itens
    await db.execute('''
      CREATE TABLE pedido_itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idPedido INTEGER NOT NULL,
        idProduto INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        totalItem REAL NOT NULL,
        ultimaAlteracao TEXT,
        FOREIGN KEY (idPedido) REFERENCES pedidos(id),
        FOREIGN KEY (idProduto) REFERENCES produtos(id)
      )
    ''');

    //pedido_pagamentos
    await db.execute('''
      CREATE TABLE pedido_pagamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idPedido INTEGER NOT NULL,
        valorPagamento REAL NOT NULL,
        ultimaAlteracao TEXT,
        FOREIGN KEY (idPedido) REFERENCES pedidos(id)
      )
    ''');
  }


  FutureOr<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE produtos ADD COLUMN novo_campo TEXT');
    }
  }

  Future<void> _insertInitialData(Database db) async {
    //admin padrão
    await db.insert('usuarios', {
      'nome': 'admin',
      'senha': 'admin',
    });

    await db.insert('usuarios', {
      'nome': 'breno',
      'senha': 'brenin',
    });

    await db.insert('usuarios', {
      'nome': 'eduardo',
      'senha': 'eduzin',
    });

    // Produtos
  await db.insert('produtos', {
    'nome': 'Caneta Azul',
    'unidade': 'un',
    'quantidadeEstoque': 100,
    'precoVenda': 2.50,
    'status': 'ativo',
    'precoCusto': 1.00,
    'codigoBarras': '1234567890123',
  });

  await db.insert('produtos', {
    'nome': 'Caderno 100 folhas',
    'unidade': 'un',
    'quantidadeEstoque': 50,
    'precoVenda': 12.90,
    'status': 'ativo',
    'precoCusto': 7.50,
    'codigoBarras': '7894561230012',
  });

  await db.insert('produtos', {
    'nome': 'Garrafa 1L',
    'unidade': 'lt',
    'quantidadeEstoque': 30,
    'precoVenda': 8.00,
    'status': 'ativo',
    'precoCusto': 5.00,
    'codigoBarras': '0001112223334',
  });

  await db.insert('produtos', {
    'nome': 'Caixa de lápis',
    'unidade': 'cx',
    'quantidadeEstoque': 20,
    'precoVenda': 15.00,
    'status': 'ativo',
    'precoCusto': 9.00,
    'codigoBarras': '3216549870001',
  });

  await db.insert('produtos', {
    'nome': 'Resma de papel A4',
    'unidade': 'cx',
    'quantidadeEstoque': 40,
    'precoVenda': 25.00,
    'status': 'ativo',
    'precoCusto': 18.00,
    'codigoBarras': '1112223334445',
  });

  // Clientes Pessoa Física
  await db.insert('clientes', {
    'nome': 'Carlos Silva',
    'tipo': 'fisica',
    'cpfCnpj': '12345678901',
    'email': 'carlos@email.com',
    'telefone': '11999999999',
    'numero': 123,
    'cep': '01001000',
    'endereco': 'Rua das Flores',
    'bairro': 'Centro',
    'cidade': 'São Paulo',
    'uf': 'SP',
  });

  await db.insert('clientes', {
    'nome': 'Ana Paula',
    'tipo': 'fisica',
    'cpfCnpj': '98765432100',
    'email': 'ana@email.com',
    'telefone': '11988888888',
    'numero': 456,
    'cep': '02002000',
    'endereco': 'Av. Brasil',
    'bairro': 'Jardins',
    'cidade': 'São Paulo',
    'uf': 'SP',
  });

  // Clientes Pessoa Jurídica
  await db.insert('clientes', {
    'nome': 'Tech Solutions Ltda',
    'tipo': 'juridica',
    'cpfCnpj': '11222333000188',
    'email': 'contato@tech.com',
    'telefone': '1133334444',
    'numero': 1000,
    'cep': '03003000',
    'endereco': 'Rua da Tecnologia',
    'bairro': 'Industrial',
    'cidade': 'Campinas',
    'uf': 'SP',
  });

  await db.insert('clientes', {
    'nome': 'Comercial ABC ME',
    'tipo': 'juridica',
    'cpfCnpj': '99887766000155',
    'email': 'abc@comercial.com',
    'telefone': '1144445555',
    'numero': 2000,
    'cep': '04004000',
    'endereco': 'Rua do Comércio',
    'bairro': 'Centro',
    'cidade': 'Santos',
    'uf': 'SP',
  });
  }
}
