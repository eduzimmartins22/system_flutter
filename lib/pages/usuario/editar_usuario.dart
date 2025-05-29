import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../controllers/usuario_controller.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const EditarUsuarioPage({this.usuario, super.key});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = UsuarioController();
  late int _id;
  late String _nome;
  late String _senha;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _id = widget.usuario?.id ?? DateTime.now().millisecondsSinceEpoch;
    _nome = widget.usuario?.nome ?? '';
    _senha = widget.usuario?.senha ?? '';

    _nomeController.text = _nome;
    _senhaController.text = _senha;
    _confirmarSenhaController.text = _senha;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarUsuario() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_senhaController.text != _confirmarSenhaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem!')),
        );
        return;
      }

      try {
        final novoUsuario = Usuario(
          id: _id,
          nome: _nomeController.text,
          senha: _senhaController.text,
        );

        bool sucesso;
        if (widget.usuario == null) {
          final nomeExiste = await _controller.nomeUsuarioExiste(novoUsuario.nome);
          if (nomeExiste) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nome de usuário já existe!')),
            );
            return;
          }
          
          await _controller.adicionarUsuario(novoUsuario);
          sucesso = true;
        } else {
          sucesso = await _controller.atualizarUsuario(novoUsuario);
        }

        if (sucesso && mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.usuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome de usuário',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome de usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha';
                  }
                  if (value != _senhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarUsuario,
                  child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (isEdicao) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmado = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: const Text('Deseja realmente excluir este usuário?'),
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

                      if (confirmado == true && mounted) {
                        final sucesso = await _controller.removerUsuario(_id);
                        if (sucesso) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Excluir Usuário'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}