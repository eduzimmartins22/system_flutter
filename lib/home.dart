import 'package:flutter/material.dart';
import 'usuario.dart';
import 'cliente.dart';
import 'produto.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
