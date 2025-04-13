import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/cliente_controler.dart';
import '../../models/cliente_model.dart';

class EditarCliente extends StatefulWidget {
  final Cliente? cliente;

  const EditarCliente({super.key, this.cliente});

  @override
  State<EditarCliente> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarCliente> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClienteController();
  
  late String _tipo;
  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _cnpjController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cepController;
  late TextEditingController _enderecoController;
  late TextEditingController _numeroController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _ufController;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    
    _tipo = cliente?.tipo ?? 'F';
    _nomeController = TextEditingController(text: cliente?.nome ?? '');
    _cpfController = TextEditingController(text: cliente?.cpf ?? '');
    _cnpjController = TextEditingController(text: cliente?.cnpj ?? '');
    _emailController = TextEditingController(text: cliente?.email ?? '');
    _numeroController = TextEditingController(
    text: cliente?.numero != null ? cliente!.numero.toString() : ''
  );
    _cepController = TextEditingController(text: cliente?.cep?.toString() ?? '');
    _enderecoController = TextEditingController(text: cliente?.endereco ?? '');
    _numeroController = TextEditingController(text: cliente?.numero?.toString() ?? '');
    _bairroController = TextEditingController(text: cliente?.bairro ?? '');
    _cidadeController = TextEditingController(text: cliente?.cidade ?? '');
    _ufController = TextEditingController(text: cliente?.uf ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cliente = Cliente(
          id: widget.cliente?.id,
          nome: _nomeController.text,
          tipo: _tipo,
          cpf: _tipo == 'F' ? _cpfController.text : null,
          cnpj: _tipo == 'J' ? _cnpjController.text : null,
          email: _emailController.text,
          numero: int.tryParse(_numeroController.text) ?? 0,
          cep: int.tryParse(_cepController.text) ?? 0,
          endereco: _enderecoController.text,
          bairro: _bairroController.text,
          cidade: _cidadeController.text,
          uf: _ufController.text,
        );

        final isEditing = widget.cliente != null;
        if (isEditing) {
          await _controller.atualizarCliente(cliente);
        } else {
          await _controller.adicionarCliente(cliente);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tipo (F/J)
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Pessoa Física')),
                  DropdownMenuItem(value: 'J', child: Text('Pessoa Jurídica')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),

              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),

              // CPF/CNPJ (condicional)
              if (_tipo == 'F')
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(labelText: 'CPF *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) => _tipo == 'F' && (value == null || value.isEmpty || value.length != 11)
                      ? 'CPF inválido (11 dígitos)'
                      : null,
                )
              else
                TextFormField(
                  controller: _cnpjController,
                  decoration: const InputDecoration(labelText: 'CNPJ *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  validator: (value) => _tipo == 'J' && (value == null || value.isEmpty || value.length != 14)
                      ? 'CNPJ inválido (14 dígitos)'
                      : null,
                ),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty || !value.contains('@') ? 'E-mail inválido' : null,
              ),

              // Telefone
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),

              // CEP
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
              ),

              // Endereço
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),

              // Número
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
              ),

              // Bairro
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),

              // Cidade
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),

              // UF
              TextFormField(
                controller: _ufController,
                decoration: const InputDecoration(labelText: 'UF'),
                maxLength: 2,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarCliente,
                child: const Text('Salvar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}