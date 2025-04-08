import 'package:flutter/material.dart';
import '../../controllers/usuario_controler.dart';
import '../../models/usuario_model.dart';

class EditarUsuario extends StatefulWidget {
  final Usuario? usuario;
  
  const EditarUsuario({super.key, this.usuario});

  @override
  State<EditarUsuario> createState() => _EditarUsuarioState();
}

class _EditarUsuarioState extends State<EditarUsuario> {
  final _formKey = GlobalKey<FormState>();
  late Usuario _usuarioEditado;
  final UsuarioController _controller = UsuarioController();

  @override
  void initState() {
    super.initState();
    _usuarioEditado = widget.usuario ?? 
      Usuario(
        id: DateTime.now().millisecondsSinceEpoch,
        nome: '',
        senha: '',
      );
  }

Future<void> _salvarUsuario() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    try {
      if (widget.usuario == null) {
        // Para novo usuário, o ID será gerado automaticamente no controller
        await _controller.adicionarUsuario(_usuarioEditado.nome, _usuarioEditado.senha);
      } else {
        // Para edição, garantimos que o ID não é nulo
        if (_usuarioEditado.id == null) {
          throw Exception('ID do usuário não pode ser nulo');
        }
        await _controller.atualizarUsuario(
          _usuarioEditado.id!, // Usamos ! para afirmar que não é nulo
          _usuarioEditado.nome, 
          _usuarioEditado.senha
        );
      }
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

   Future<void> _excluirUsuario() async {
    if (widget.usuario != null && widget.usuario!.id != null) {
      final success = await _controller.removerUsuario(widget.usuario!.id!);
      if (!mounted) return;
      Navigator.pop(context, success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null ? 'Novo Usuário' : 'Editar Usuário'),
        actions: [
          if (widget.usuario != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Deseja realmente excluir este usuário?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _excluirUsuario();
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.usuario != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'ID: ${_usuarioEditado.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              TextFormField(
                initialValue: _usuarioEditado.nome,
                decoration: const InputDecoration(
                  labelText: 'Nome do Usuário *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
                onChanged: (value) => _usuarioEditado = _usuarioEditado.copyWith(nome: value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _usuarioEditado.senha,
                decoration: const InputDecoration(
                  labelText: 'Senha *',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
                onChanged: (value) => _usuarioEditado = _usuarioEditado.copyWith(senha: value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarUsuario,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}