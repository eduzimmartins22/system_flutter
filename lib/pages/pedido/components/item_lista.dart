import 'package:flutter/material.dart';
import 'item_form.dart';
import '../../../../models/pedido_model.dart';
import '../../../../controllers/produto_controller.dart';

class ItemLista extends StatefulWidget {
  final List<PedidoItem> itens;
  final Function(int) onRemoverItem;
  final Function(PedidoItem) onAdicionarItem;

  const ItemLista({
    super.key,
    required this.itens,
    required this.onRemoverItem,
    required this.onAdicionarItem,
  });

  @override
  State<ItemLista> createState() => _ItemListaState();
}

class _ItemListaState extends State<ItemLista> {
  final Map<int, String> _nomesProdutos = {};
  bool _carregandoNomes = false;

  @override
  void initState() {
    super.initState();
    _carregarNomesProdutos();
  }

  Future<void> _carregarNomesProdutos() async {
    if (widget.itens.isEmpty) return;
    
    setState(() => _carregandoNomes = true);
    
    final controller = ProdutoController();
    for (final item in widget.itens) {
      if (!_nomesProdutos.containsKey(item.idProduto)) {
        final produto = await controller.getProdutoPorId(item.idProduto);
        if (produto != null) {
          _nomesProdutos[item.idProduto] = produto.nome;
        }
      }
    }
    
    setState(() => _carregandoNomes = false);
  }

  @override
  void didUpdateWidget(covariant ItemLista oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itens != oldWidget.itens) {
      _carregarNomesProdutos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Itens do Pedido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _mostrarFormularioItem(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_carregandoNomes)
              const Center(child: CircularProgressIndicator())
            else if (widget.itens.isEmpty)
              const Center(child: Text('Nenhum item adicionado'))
            else
              Column(
              children: ListTile.divideTiles(
                context: context,
                tiles: widget.itens.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final nomeProduto = _nomesProdutos[item.idProduto] ?? 'Produto #${item.idProduto}';
                  return ListTile(
                    title: Text(nomeProduto),
                    subtitle: Text(
                      '${item.quantidade} x R\$${(item.totalItem/item.quantidade).toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onRemoverItem(index),
                    ),
                  );
                }).toList(),
                color: Colors.grey.shade300, // Cor do divisor
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder( // Adiciona bordas arredondadas
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: ItemForm(onSubmit: widget.onAdicionarItem),
            ),
          ),
        ),
      ),
    );
  }
}