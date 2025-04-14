import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../controllers/cliente_controller.dart';
import 'editar_cliente.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final ClienteController _controller = ClienteController();
  late Future<List<Cliente>> _futureClientes;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  void _carregarClientes() {
    setState(() {
      _futureClientes = _controller.getClientes();
    });
  }

  void _editarCliente(Cliente cliente) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarClientePage(cliente: cliente),
      ),
    );
    
    if (resultado == true) {
      _carregarClientes();
    }
  }

  void _adicionarCliente() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditarClientePage(),
      ),
    );
    
    if (resultado == true) {
      _carregarClientes();
    }
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o cliente ${cliente.nome}?'),
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
      final sucesso = await _controller.removerCliente(cliente.id);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso')),
        );
        _carregarClientes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
      ),
      body: FutureBuilder<List<Cliente>>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado'));
          }

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                title: Text(cliente.nome),
                subtitle: Text('${cliente.tipo.descricao} - ${cliente.cpfCnpj}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarCliente(cliente),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarExclusao(cliente),
                    ),
                  ],
                ),
                onTap: () => _editarCliente(cliente),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarCliente,
        icon: const Icon(Icons.add),
        label: const Text("Novo Cliente"),
      ),
    );
  }
}