import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final UsuarioController _usuarioController = UsuarioController();

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    final username = _userController.text;
    final password = _passwordController.text;

    if (username == 'admin' && password == 'admin') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logado', true);
      await prefs.setString('nomeUsuario', 'admin');
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      final usuario = await _usuarioController.buscarPorNomeESenha(username, password);
      
      if (usuario != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logado', true);
        await prefs.setString('nomeUsuario', usuario.nome);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário ou senha inválidos!')),
          );
        }
      }
    }
    
    if (mounted) {
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
                const FlutterLogo(size: 100),
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