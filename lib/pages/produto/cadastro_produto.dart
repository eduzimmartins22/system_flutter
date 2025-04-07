import 'package:flutter/material.dart';
import '../../controllers/produto_controller.dart';
import '../../models/produto_model.dart';
import 'editar_produto.dart';

class CadastroProduto extends StatefulWidget {
  const CadastroProduto({super.key});

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  final ProdutoController _controller = ProdutoController();
  late Future<List<Produto>> _loadProducts;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _loadProducts = _controller.getProdutos()
        .then((lista) => lista..sort((a, b) => b.id.compareTo(a.id)));
    });
  }

  void _navegarParaEdicao(Produto? produto) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProduto(produto: produto),
      ),
    ) ?? false;
    
    if (result) _carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
      ),
      body: FutureBuilder<List<Produto>>(
        future: _loadProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }
          
          final produtos = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(produto.nome),
                  subtitle: Text(
                    '${produto.unidade.descricao} - R\$${produto.precoVenda.toStringAsFixed(2)}',
                  ),
                  trailing: Text('Estoque: ${produto.quantidadeEstoque}'),
                  onTap: () => _navegarParaEdicao(produto),
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