import 'package:flutter/material.dart';
import '../../../../controllers/cliente_controller.dart';
import '../../../../models/cliente_model.dart';

class ClienteSelecao extends StatefulWidget {
  final Function(int) onClienteSelecionado;

  const ClienteSelecao({super.key, required this.onClienteSelecionado});

  @override
  State<ClienteSelecao> createState() => _ClienteSelecaoState();
}

class _ClienteSelecaoState extends State<ClienteSelecao> {
  final ClienteController _clienteController = ClienteController();
  late Future<List<Cliente>> _futureClientes;
  int? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    _futureClientes = _clienteController.getClientes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cliente>>(
      future: _futureClientes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Erro ao carregar clientes');
        }

        final clientes = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cliente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _clienteSelecionado,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: 'Selecione um cliente',
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  items: clientes.map((cliente) {
                    return DropdownMenuItem<int>(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _clienteSelecionado = value);
                    if (value != null) {
                      widget.onClienteSelecionado(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) return 'Selecione um cliente';
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