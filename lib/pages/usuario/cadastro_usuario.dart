import 'package:flutter/material.dart';
import '../../controllers/usuario_controler.dart';
import '../../models/usuario_model.dart';
import 'editar_usuario.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  final UsuarioController _controller = UsuarioController();
  late Future<List<Usuario>> _loadUsers;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    setState(() {
      _loadUsers = _controller.getUsuarios()
        .then((lista) => lista..sort((a, b) {
          // Trata IDs nulos (considera 0 quando for nulo)
          final aId = a.id ?? 0;
          final bId = b.id ?? 0;
          return bId.compareTo(aId); // Ordena decrescente
        }));
    });
  }

  void _navegarParaEdicao(Usuario? usuario) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuario(usuario: usuario),
      ),
    ) ?? false;
    
    if (result) _carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuários'),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _loadUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar usuários'));
          }
          
          final usuarios = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(usuario.nome),
                  subtitle: Text('ID: ${usuario.id ?? "Gerando..."}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _navegarParaEdicao(usuario),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaEdicao(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}