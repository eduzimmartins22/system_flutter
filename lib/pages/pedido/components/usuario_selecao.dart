import 'package:flutter/material.dart';
import '../../../../controllers/usuario_controller.dart';
import '../../../../models/usuario_model.dart';

class UsuarioSelecao extends StatefulWidget {
  final Function(int) onUsuarioSelecionado;
  final int? usuarioIdInicial;
  final int? usuarioLogadoId;

  const UsuarioSelecao({
    super.key,
    required this.onUsuarioSelecionado,
    this.usuarioIdInicial,
    this.usuarioLogadoId,
  });

  @override
  State<UsuarioSelecao> createState() => _UsuarioSelecaoState();
}

class _UsuarioSelecaoState extends State<UsuarioSelecao> {
  final UsuarioController _usuarioController = UsuarioController();
  late Future<List<Usuario>> _futureUsuarios;
  int? _usuarioSelecionado;

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _usuarioController.getUsuarios();
    _usuarioSelecionado = widget.usuarioIdInicial ?? widget.usuarioLogadoId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _futureUsuarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Erro ao carregar usuários');
        }

        final usuarios = snapshot.data!.where((u) => u.nome != 'admin').toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuário Responsável',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _usuarioSelecionado,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: 'Selecione um usuário',
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  items: usuarios.map((usuario) {
                    return DropdownMenuItem<int>(
                      value: usuario.id,
                      child: Text(usuario.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _usuarioSelecionado = value);
                    if (value != null) {
                      widget.onUsuarioSelecionado(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) return 'Selecione um usuário';
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}