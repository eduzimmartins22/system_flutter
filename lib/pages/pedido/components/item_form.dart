import 'package:flutter/material.dart';
import '../../../../controllers/produto_controller.dart';
import '../../../../models/produto_model.dart';
import '../../../../models/pedido_model.dart';

class ItemForm extends StatefulWidget {
  final Function(PedidoItem) onSubmit;

  const ItemForm({super.key, required this.onSubmit});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController(text: '1');
  final ProdutoController _produtoController = ProdutoController();
  late Future<List<Produto>> _futureProdutos;
  Produto? _produtoSelecionado;
  double _precoUnitario = 0;
  double _totalItem = 0;

  @override
  void initState() {
    super.initState();
    _futureProdutos = _produtoController.buscarProdutosAtivos();
    _quantidadeController.addListener(_calcularTotal);
  }

  @override
  void dispose() {
    _quantidadeController.removeListener(_calcularTotal);
    super.dispose();
  }

  void _calcularTotal() {
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    setState(() {
      _totalItem = quantidade * _precoUnitario;
    });
  }

  void _onProdutoSelecionado(Produto? produto) {
    setState(() {
      _produtoSelecionado = produto;
      _precoUnitario = produto?.precoVenda ?? 0;
      _calcularTotal();
    });
  }

  void _salvarItem() {
    if (_formKey.currentState!.validate()) {
      if (_produtoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um produto')),
        );
        return;
      }

      final item = PedidoItem(
        id: 0,
        idPedido: 0,
        idProduto: _produtoSelecionado!.id,
        quantidade: int.parse(_quantidadeController.text),
        totalItem: _totalItem,
      );
      widget.onSubmit(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Importante para diálogos
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Adicionar Produto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Campo de Produto
          FutureBuilder<List<Produto>>(
            future: _futureProdutos,
            builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Text('Erro ao carregar produtos');
                  }
                  
                  final produtos = snapshot.data!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Produto'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                        ),
                        child: DropdownButtonFormField<Produto>(
                          value: _produtoSelecionado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          items: produtos.map((produto) {
                            return DropdownMenuItem<Produto>(
                              value: produto,
                              child: Text(produto.nome),
                            );
                          }).toList(),
                          onChanged: _onProdutoSelecionado,
                          validator: (value) {
                            if (value == null) return 'Selecione um produto';
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Campo de Quantidade
              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a quantidade';
                  if (int.tryParse(value) == null) return 'Quantidade inválida';
                  if (int.parse(value) <= 0) return 'Quantidade deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Informações de preço
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Preço unitário:'),
                        Text('R\$${_precoUnitario.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'R\$${_totalItem.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botões
              Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _salvarItem,
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}