import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(SalesApp());
}

class SalesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Força de Venda',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  void _login() {
    String username = _userController.text;
    String password = _passwordController.text;
    if (username == 'admin' && password == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário ou senha inválidos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: InputDecoration(labelText: 'Usuário')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Entrar')),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserRegistrationPage())),
            child: Text('Cadastro de Usuário'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientRegistrationPage())),
            child: Text('Cadastro de Cliente'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductRegistrationPage())),
            child: Text('Cadastro de Produto'),
          ),
        ],
      ),
    );
  }
}

class UserRegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuário')),
      body: Center(child: Text('Tela de Cadastro de Usuário')),
    );
  }
}

class ClientRegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Cliente')),
      body: Center(child: Text('Tela de Cadastro de Cliente')),
    );
  }
}

class ProductRegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produto')),
      body: Center(child: Text('Tela de Cadastro de Produto')),
    );
  }
}

// Classe para manipulação de arquivos JSON
class FileHelper {
  static Future<File> _getFile(String fileName) async {
    final directory = Directory.current;
    return File('${directory.path}/$fileName.json');
  }

  static Future<List<dynamic>> readData(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (!await file.exists()) return [];
      String content = await file.readAsString();
      return json.decode(content);
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeData(String fileName, List<dynamic> data) async {
    final file = await _getFile(fileName);
    await file.writeAsString(json.encode(data));
  }
}
