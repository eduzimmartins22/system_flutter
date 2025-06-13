import 'package:flutter/material.dart';
import '../../models/produto_model.dart';
import '../../controllers/produto_controller.dart';
import 'editar_produto.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final ProdutoController _controller = ProdutoController();
  late Future<List<Produto>> _futureProdutos;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _futureProdutos = _controller.getProdutos();
    });
  }

  void _editarProduto(Produto produto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProdutoPage(produto: produto),
      ),
    );
    
    if (resultado == true) {
      _carregarProdutos();
    }
  }

  void _adicionarProduto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditarProdutoPage(),
      ),
    );
    
    if (resultado == true) {
      _carregarProdutos();
    }
  }

  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o produto ${produto.nome}?'),
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
      final sucesso = await _controller.removerProduto(produto.id);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso')),
        );
        _carregarProdutos();
      }
    }
  }

  Widget _buildProductCard(BuildContext context, Produto produto) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editarProduto(produto),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag,
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
                          produto.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estoque: ${produto.qtdEstoque} ${produto.unidade.descricao}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            iconSize: 24,
                            onPressed: () => _confirmarExclusao(produto),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 1,
              left: 1,
              
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: produto.Status == StatusProduto.ativo
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  produto.Status.descricao,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: produto.Status == StatusProduto.ativo
                            ? Colors.green
                            : Colors.grey,
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
        title: const Text('Produtos Cadastrados'),
      ),
      body: FutureBuilder<List<Produto>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final produtos = snapshot.data ?? [];

          if (produtos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return _buildProductCard(context, produto);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarProduto,
        icon: const Icon(Icons.add),
        label: const Text('Novo Produto'),
      ),
    );
  }
}