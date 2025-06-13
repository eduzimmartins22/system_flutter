import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const int _newVersion = 3;
  
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
        version: _newVersion,
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

  FutureOr<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

    }
  }

  Future<void> _createTables(Database db) async {
    //usuario
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL,
        ultimaAlteracao TEXT,
        deletado INTEGER NOT NULL DEFAULT 0,
        CONSTRAINT usuario_nome_unico UNIQUE (nome)
      )
    ''');

    //produto
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        unidade TEXT NOT NULL CHECK (unidade IN ('Un', 'Cx', 'Kg', 'Lt', 'Ml')),
        qtdEstoque REAL NOT NULL DEFAULT 0,
        precoVenda REAL NOT NULL CHECK (precoVenda >= 0),
        custo REAL,
        codigoBarra TEXT,
        Status INTEGER NOT NULL CHECK (Status IN (0, 1)),
        ultimaAlteracao TEXT,
        deletado INTEGER NOT NULL DEFAULT 0,
        CONSTRAINT estoque_positivo CHECK (qtdEstoque >= 0),
        CONSTRAINT produto_nome_unico UNIQUE (nome)
      );
    ''');

    //cliente
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK (tipo IN ('F', 'J')),
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        cep TEXT,
        endereco TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        ultimaAlteracao TEXT,
        deletado INTEGER NOT NULL DEFAULT 0,
        CONSTRAINT cpf_cnpj_unico UNIQUE (cpfCnpj),
        CONSTRAINT cpf_length CHECK (
          (tipo = 'F' AND LENGTH(cpfCnpj) = 11) OR
          (tipo = 'J' AND LENGTH(cpfCnpj) = 14)
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
        deletado INTEGER NOT NULL DEFAULT 0,
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
        quantidade REAL NOT NULL,
        totalItem REAL NOT NULL,
        ultimaAlteracao TEXT,
        deletado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (idPedido) REFERENCES pedidos(id),
        FOREIGN KEY (idProduto) REFERENCES produtos(id)
      )
    ''');

    //pedido_pagamentos
    await db.execute('''
      CREATE TABLE pedido_pagamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idPedido INTEGER NOT NULL,
        valor REAL NOT NULL,
        ultimaAlteracao TEXT,
        deletado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (idPedido) REFERENCES pedidos(id)
      )
    ''');
  }

  Future<void> _insertInitialData(Database db) async {
    /* 
      A gente usava essa praga aqui pra toda vez que limpasse os dados do app não ficar colocando tudo manualmente.
    */
  } 
}
