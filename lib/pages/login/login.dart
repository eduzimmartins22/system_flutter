import 'package:flutter/material.dart';
import '../../controllers/usuario_controller.dart';
import '../home/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hasUsers = false;
  final UsuarioController _usuarioController = UsuarioController();

  @override
  void initState() {
    super.initState();
    _checkIfHasUsers();
  }

  Future<void> _checkIfHasUsers() async {
    try {
      final users = await _usuarioController.getUsuarios();
      setState(() {
        _hasUsers = users.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _hasUsers = true;
      });
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    final username = _userController.text;
    final password = _passwordController.text;

    try {
      if (username == 'admin' && password == 'admin') {
        if (!_hasUsers) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage(
              userName: 'admin',
              userId: null,
            )),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login de admin não permitido quando há usuários cadastrados!')),
          );
          return;
        }
      }
    
      final usuario = await _usuarioController.buscarPorNomeESenha(username, password);
      
      if (usuario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(
            userName: usuario.nome,
            userId: usuario.id,
          )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha inválidos!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/shop.png',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}