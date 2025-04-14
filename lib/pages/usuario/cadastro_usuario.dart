import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../controllers/usuario_controller.dart';
import 'editar_usuario.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final UsuarioController _controller = UsuarioController();
  late Future<List<Usuario>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    setState(() {
      _futureUsuarios = _controller.getUsuarios();
    });
  }

  void _editarUsuario(Usuario usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuarioPage(usuario: usuario),
    ));
    
    if (resultado == true) {
      _carregarUsuarios();
    }
  }

  void _adicionarUsuario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditarUsuarioPage()),
    );
    
    if (resultado == true) {
      _carregarUsuarios();
    }
  }

  Future<void> _confirmarExclusao(Usuario usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o usuário ${usuario.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final sucesso = await _controller.removerUsuario(usuario.id);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário excluído com sucesso')),
        );
        _carregarUsuarios();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários Cadastrados'),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(child: Text('Nenhum usuário cadastrado'));
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                title: Text(usuario.nome),
                subtitle: Text('ID: ${usuario.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarUsuario(usuario),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarExclusao(usuario),
                    ),
                  ],
                ),
                onTap: () => _editarUsuario(usuario),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarUsuario,
        icon: const Icon(Icons.add),
        label: const Text("Novo Usuário"),
      ),
    );
  }
}