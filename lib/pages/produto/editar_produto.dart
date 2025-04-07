import 'package:flutter/material.dart';
import '../../controllers/produto_controller.dart';
import '../../models/produto_model.dart';

class EditarProduto extends StatefulWidget {
  final Produto? produto;
  
  const EditarProduto({super.key, this.produto});

  @override
  State<EditarProduto> createState() => _EditarProdutoState();
}

class _EditarProdutoState extends State<EditarProduto> {
  final _formKey = GlobalKey<FormState>();
  late Produto _produtoEditado;
  final ProdutoController _controller = ProdutoController();

  @override
  void initState() {
    super.initState();
    _produtoEditado = widget.produto ?? 
      Produto(
        id: DateTime.now().millisecondsSinceEpoch,
        nome: '',
        unidade: UnidadeProduto.un,
        quantidadeEstoque: 0,
        precoVenda: 0,
        status: StatusProduto.ativo,
        precoCusto: null,
        codigoBarras: null,
      );
  }

  Future<void> _salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final success = widget.produto == null 
            ? await _controller.adicionarProduto(_produtoEditado) != null
            : await _controller.atualizarProduto(_produtoEditado);
        
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context, false);
      }
    }
  }

  Future<void> _excluirProduto() async {
    if (widget.produto != null) {
      final success = await _controller.removerProduto(widget.produto!.id);
      if (!mounted) return;
      Navigator.pop(context, success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto'),
        actions: [
          if (widget.produto != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Deseja realmente excluir este produto?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _excluirProduto();
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _produtoEditado.nome,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
                onSaved: (value) => _produtoEditado = _produtoEditado.copyWith(nome: value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UnidadeProduto>(
                value: _produtoEditado.unidade,
                items: UnidadeProduto.values.map((unidade) {
                  return DropdownMenuItem(
                    value: unidade,
                    child: Text(unidade.descricao),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _produtoEditado = _produtoEditado.copyWith(unidade: value);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Unidade *',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _produtoEditado.quantidadeEstoque.toString(),
                decoration: const InputDecoration(
                  labelText: 'Quantidade em Estoque *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
                onSaved: (value) => _produtoEditado = _produtoEditado.copyWith(
                  quantidadeEstoque: int.parse(value!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _produtoEditado.precoVenda.toString(),
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda *',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
                onSaved: (value) => _produtoEditado = _produtoEditado.copyWith(
                  precoVenda: double.parse(value!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _produtoEditado.precoCusto?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Preço de Custo',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
                onSaved: (value) => _produtoEditado = _produtoEditado.copyWith(
                  precoCusto: value?.isEmpty ?? true ? null : double.parse(value!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _produtoEditado.codigoBarras,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras',
                ),
                keyboardType: TextInputType.text,
                onSaved: (value) => _produtoEditado = _produtoEditado.copyWith(
                  codigoBarras: value?.isEmpty ?? true ? null : value,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StatusProduto>(
                value: _produtoEditado.status,
                items: StatusProduto.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.descricao),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _produtoEditado = _produtoEditado.copyWith(status: value);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Status *',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarProduto,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}