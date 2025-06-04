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
    //await _insertInitialData(db);
  }

  Future<void> _createTables(Database db) async {
    //usuario
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL,
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
        dataCadastro TEXT NOT NULL DEFAULT (datetime('now')),
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
        FOREIGN KEY (idPedido) REFERENCES pedidos(id)
      )
    ''');
  }


  FutureOr<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE produtos ADD COLUMN novo_campo TEXT');
    }
  }

  // Future<void> _insertInitialData(Database db) async {
  //   //admin padrão
  //   await db.insert('usuarios', {
  //     'nome': 'admin',
  //     'senha': 'admin',
  //   }, conflictAlgorithm: ConflictAlgorithm.ignore);
  // }
}
