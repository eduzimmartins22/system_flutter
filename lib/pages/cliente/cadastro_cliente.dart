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
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso')),
        );
        _carregarClientes();
      }
    }
  }

  Widget _buildClienteCard(BuildContext context, Cliente cliente) {
    final bool isPessoaFisica = cliente.tipo.descricao.toLowerCase().contains('física');
    final Color badgeColor = isPessoaFisica
        ? Colors.green.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);
    final Color badgeTextColor = isPessoaFisica ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editarCliente(cliente),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cliente.cpfCnpjFormatado,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        iconSize: 24,
                        onPressed: () => _confirmarExclusao(cliente),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cliente.tipo.descricao,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return _buildClienteCard(context, cliente);
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
