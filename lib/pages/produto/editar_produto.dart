import 'package:flutter/material.dart';
import '../../models/produto_model.dart';
import '../../controllers/produto_controller.dart';

class EditarProdutoPage extends StatefulWidget {
  final Produto? produto;

  const EditarProdutoPage({this.produto, super.key});

  @override
  State<EditarProdutoPage> createState() => _EditarProdutoPageState();
}

class _EditarProdutoPageState extends State<EditarProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProdutoController();
  late Produto _produto;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _precoVendaController = TextEditingController();
  final TextEditingController _precoCustoController = TextEditingController();
  final TextEditingController _codigoBarrasController = TextEditingController();

  UnidadeProduto _unidadeSelecionada = UnidadeProduto.un;
  StatusProduto _statusSelecionado = StatusProduto.ativo;

  @override
  void initState() {
    super.initState();
    _produto = widget.produto ?? Produto(
      id: 0,
      nome: '',
      unidade: UnidadeProduto.un,
      quantidadeEstoque: 0,
      precoVenda: 0,
      status: StatusProduto.ativo,
    );

    _nomeController.text = _produto.nome;
    _quantidadeController.text = _produto.quantidadeEstoque.toString();
    _precoVendaController.text = _produto.precoVenda.toString();
    _precoCustoController.text = _produto.precoCusto?.toString() ?? '';
    _codigoBarrasController.text = _produto.codigoBarras ?? '';
    _unidadeSelecionada = _produto.unidade;
    _statusSelecionado = _produto.status;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoVendaController.dispose();
    _precoCustoController.dispose();
    _codigoBarrasController.dispose();
    super.dispose();
  }

  Future<void> _salvarProduto() async {
    if (_formKey.currentState?.validate() ?? false) {
      final novoProduto = Produto(
        id: widget.produto?.id ?? 0,
        nome: _nomeController.text,
        unidade: _unidadeSelecionada,
        quantidadeEstoque: int.parse(_quantidadeController.text),
        precoVenda: double.parse(_precoVendaController.text),
        status: _statusSelecionado,
        precoCusto: _precoCustoController.text.isNotEmpty 
            ? double.parse(_precoCustoController.text) 
            : null,
        codigoBarras: _codigoBarrasController.text.isNotEmpty
            ? _codigoBarrasController.text
            : null,
      );

      bool sucesso;
      if (widget.produto == null) {
        await _controller.adicionarProduto(novoProduto);
        sucesso = true;
      } else {
        sucesso = await _controller.atualizarProduto(novoProduto);
      }

      if (sucesso) {
        Navigator.pop(context, true);
      }
    }
  }

@override
Widget build(BuildContext context) {
  final isEdicao = widget.produto != null;

  return Scaffold(
    appBar: AppBar(
      title: Text(isEdicao ? 'Editar Produto' : 'Novo Produto'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome do produto';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UnidadeProduto>(
              value: _unidadeSelecionada,
              items: UnidadeProduto.values.map((unidade) {
                return DropdownMenuItem(
                  value: unidade,
                  child: Text(unidade.descricao),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _unidadeSelecionada = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Unidade'),
              validator: (value) {
                if (value == null || value == UnidadeProduto.un) {
                  return 'Por favor, selecione uma unidade válida';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade em Estoque'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a quantidade';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Insira um número maior que zero';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precoVendaController,
              decoration: const InputDecoration(labelText: 'Preço de Venda'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o preço de venda';
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Insira um valor numérico válido';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precoCustoController,
              decoration: const InputDecoration(labelText: 'Preço de Custo'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
               validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o preço de venda';
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Insira um valor numérico válido';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoBarrasController,
              decoration: const InputDecoration(labelText: 'Código de Barras'),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StatusProduto>(
              value: _statusSelecionado,
              items: StatusProduto.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.descricao),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _statusSelecionado = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Status'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvarProduto,
                child: const Text('Salvar'),
              ),
            ),
            if (isEdicao) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmado = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar Exclusão'),
                        content: const Text('Deseja realmente excluir este produto?'),
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
                      final sucesso = await _controller.removerProduto(_produto.id);
                      if (sucesso) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Excluir Produto'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}