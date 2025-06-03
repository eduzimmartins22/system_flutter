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
  bool _isLoading = false;

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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final sucesso = await _controller.removerCliente(cliente.id!);
        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarClientes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir cliente: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para atualizar a lista após mudanças
  Future<void> _atualizarLista() async {
    setState(() {
      _futureClientes = _controller.getClientes();
    });
  }

  Widget _buildClienteCard(BuildContext context, Cliente cliente) {
    // Determinar se é pessoa física ou jurídica baseado no CPF/CNPJ
    final bool isPessoaFisica = cliente.cpfCnpj.length == 11;
    final Color badgeColor = isPessoaFisica
        ? Colors.green.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);
    final Color badgeTextColor = isPessoaFisica ? Colors.green : Colors.orange;
    final String tipoDescricao = isPessoaFisica ? 'Pessoa Física' : 'Pessoa Jurídica';

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
                      isPessoaFisica ? Icons.person : Icons.business,
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
                          _formatarDocumento(cliente.cpfCnpj),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (cliente.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            cliente.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (cliente.telefone != null && cliente.telefone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            cliente.telefone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
                        onPressed: _isLoading ? null : () => _confirmarExclusao(cliente),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tipoDescricao,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            // Indicador de status ativo/inativo
            if (!cliente.ativo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Inativo',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.red,
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

  // Formatar CPF/CNPJ para exibição
  String _formatarDocumento(String documento) {
    if (documento.length == 11) {
      // CPF: 000.000.000-00
      return '${documento.substring(0, 3)}.${documento.substring(3, 6)}.${documento.substring(6, 9)}-${documento.substring(9)}';
    } else if (documento.length == 14) {
      // CNPJ: 00.000.000/0000-00
      return '${documento.substring(0, 2)}.${documento.substring(2, 5)}.${documento.substring(5, 8)}/${documento.substring(8, 12)}-${documento.substring(12)}';
    }
    return documento;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _atualizarLista,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Cliente>>(
            future: _futureClientes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar clientes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _atualizarLista,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              final clientes = snapshot.data ?? [];

              if (clientes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum cliente cadastrado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione seu primeiro cliente usando o botão abaixo',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _atualizarLista,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return _buildClienteCard(context, cliente);
                  },
                ),
              );
            },
          ),
          // Overlay de loading durante exclusão
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _adicionarCliente,
        icon: const Icon(Icons.add),
        label: const Text("Novo Cliente"),
      ),
    );
  }
}