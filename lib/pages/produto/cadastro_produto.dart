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
    ));
    
    if (resultado == true) {
      _carregarProdutos();
    }
  }

  void _adicionarProduto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditarProdutoPage()),
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
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso')),
        );
        _carregarProdutos();
      }
    }
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final produtos = snapshot.data ?? [];

          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado'));
          }

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ListTile(
                title: Text(produto.nome),
                subtitle: Text(
                  '${produto.quantidadeEstoque} ${produto.unidade.descricao} - '
                  'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarProduto(produto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarExclusao(produto),
                    ),
                  ],
                ),
                onTap: () => _editarProduto(produto),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarProduto,
        icon: const Icon(Icons.add),
        label: const Text("Novo Produto"),
      ),
    );
  }
}