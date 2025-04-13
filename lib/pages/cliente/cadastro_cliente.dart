import 'package:flutter/material.dart';
import '../../controllers/cliente_controler.dart';
import '../../models/cliente_model.dart';
import 'editar_cliente.dart';

class CadastroCliente extends StatefulWidget {
  const CadastroCliente({super.key});

  @override
  State<CadastroCliente> createState() => _CadastroClienteState();
}

class _CadastroClienteState extends State<CadastroCliente> {
  final ClienteController _controller = ClienteController();
  late Future<List<Cliente>> _loadClients;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  void _carregarClientes() {
    setState(() {
      _loadClients = _controller.getClientes()
        .then((lista) => lista..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)));
    });
  }

  void _navegarParaEdicao(Cliente? cliente) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCliente(cliente: cliente),
      ),
    ) ?? false;
    
    if (result) _carregarClientes();
  }

  void _confirmarExclusao(Cliente cliente) async {
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
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final sucesso = await _controller.removerCliente(cliente.id!);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente ${cliente.nome} removido com sucesso')),
        );
        _carregarClientes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarClientes,
          ),
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: _loadClients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar clientes: ${snapshot.error}'),
            );
          }
          
          final clientes = snapshot.data ?? [];
          
          if (clientes.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente cadastrado'),
            );
          }
          
          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(cliente.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente.tipo == 'F' 
                          ? 'CPF: ${cliente.cpf}' 
                          : 'CNPJ: ${cliente.cnpj}'),
                      Text('${cliente.cidade}/${cliente.uf}'),
                      Text(cliente.email),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(cliente),
                  ),
                  onTap: () => _navegarParaEdicao(cliente),
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