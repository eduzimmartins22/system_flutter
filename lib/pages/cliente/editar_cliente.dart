import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../controllers/cliente_controller.dart';

class EditarClientePage extends StatefulWidget {
  final Cliente? cliente;

  const EditarClientePage({this.cliente, super.key});

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClienteController();
  late int _id;
  late TipoCliente _tipoSelecionado;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _id = widget.cliente?.id ?? DateTime.now().millisecondsSinceEpoch;
    _tipoSelecionado = widget.cliente?.tipo ?? TipoCliente.fisica;

    if (widget.cliente != null) {
      _nomeController.text = widget.cliente!.nome;
      _cpfCnpjController.text = widget.cliente!.cpfCnpj;
      _emailController.text = widget.cliente!.email ?? '';
      _numeroController.text = widget.cliente!.numero?.toString() ?? '';
      _cepController.text = widget.cliente!.cep ?? '';
      _enderecoController.text = widget.cliente!.endereco ?? '';
      _bairroController.text = widget.cliente!.bairro ?? '';
      _cidadeController.text = widget.cliente!.cidade ?? '';
      _ufController.text = widget.cliente!.uf ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final novoCliente = Cliente(
          id: _id,
          nome: _nomeController.text,
          tipo: _tipoSelecionado,
          cpfCnpj: _cpfCnpjController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          numero: _numeroController.text.isNotEmpty ? int.parse(_numeroController.text) : null,
          cep: _cepController.text.isNotEmpty ? _cepController.text : null,
          endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
          bairro: _bairroController.text.isNotEmpty ? _bairroController.text : null,
          cidade: _cidadeController.text.isNotEmpty ? _cidadeController.text : null,
          uf: _ufController.text.isNotEmpty ? _ufController.text : null,
        );

        bool sucesso;
        if (widget.cliente == null) {
          if (await _controller.documentoExiste(novoCliente.cpfCnpj)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Já existe um cliente com este documento!')),
            );
            return;
          }
          await _controller.adicionarCliente(novoCliente);
          sucesso = true;
        } else {
          if (await _controller.documentoExiste(novoCliente.cpfCnpj, novoCliente.id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Já existe um cliente com este documento!')),
            );
            return;
          }
          sucesso = await _controller.atualizarCliente(novoCliente);
        }

        if (sucesso) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.cliente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<TipoCliente>(
                value: _tipoSelecionado,
                items: TipoCliente.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.descricao),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoSelecionado = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cliente *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                decoration: InputDecoration(
                  labelText: _tipoSelecionado == TipoCliente.fisica ? 'CPF *' : 'CNPJ *',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira o documento';
                  if (_tipoSelecionado == TipoCliente.fisica && value.length != 11) return 'CPF deve ter 11 dígitos';
                  if (_tipoSelecionado == TipoCliente.juridica && value.length != 14) return 'CNPJ deve ter 14 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(height: 16),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  BuscarCepButton(
  cepController: _cepController,
  enderecoController: _enderecoController,
  bairroController: _bairroController,
  cidadeController: _cidadeController,
  ufController: _ufController,
),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _ufController,
                      decoration: const InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarCliente,
                  child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (isEdicao) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmado = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: const Text('Deseja realmente excluir este cliente?'),
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
                        final sucesso = await _controller.removerCliente(_id);
                        if (sucesso) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Excluir Cliente'),
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

// =======================
// Componente de botão separado
// =======================

class BuscarCepButton extends StatefulWidget {
  final TextEditingController cepController;
  final TextEditingController enderecoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController ufController;

  const BuscarCepButton({
    Key? key,
    required this.cepController,
    required this.enderecoController,
    required this.bairroController,
    required this.cidadeController,
    required this.ufController,
  }) : super(key: key);

  @override
  State<BuscarCepButton> createState() => _BuscarCepButtonState();
}

class _BuscarCepButtonState extends State<BuscarCepButton> {
  final ClienteController _controller = ClienteController();
  bool _carregando = false;

  Future<void> _buscarCep() async {
    final cep = widget.cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP deve ter 8 dígitos')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final endereco = await _controller.buscarEnderecoPorCep(cep);
      widget.enderecoController.text = endereco['logradouro'] ?? '';
      widget.bairroController.text = endereco['bairro'] ?? '';
      widget.cidadeController.text = endereco['cidade'] ?? '';
      widget.ufController.text = endereco['uf'] ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: _carregando ? null : _buscarCep,
        child: _carregando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Buscar'),
      ),
    );
  }
}
