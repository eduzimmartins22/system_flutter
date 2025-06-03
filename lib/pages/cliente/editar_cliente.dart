import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../controllers/cliente_controller.dart';

// Enum para controlar o tipo de cliente na interface
enum TipoCliente {
  fisica('Pessoa Física'),
  juridica('Pessoa Jurídica');

  const TipoCliente(this.descricao);
  final String descricao;
}

class EditarClientePage extends StatefulWidget {
  final Cliente? cliente;

  const EditarClientePage({this.cliente, super.key});

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClienteController();
  late TipoCliente _tipoSelecionado;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Determina o tipo baseado no CPF/CNPJ ou usa padrão
    if (widget.cliente != null) {
      final cpfCnpjLimpo = widget.cliente!.cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');
      _tipoSelecionado = cpfCnpjLimpo.length == 11 ? TipoCliente.fisica : TipoCliente.juridica;
      
      // Preenche os campos com os dados do cliente
      _nomeController.text = widget.cliente!.nome;
      _cpfCnpjController.text = widget.cliente!.cpfCnpj;
      _emailController.text = widget.cliente!.email;
      _telefoneController.text = widget.cliente!.telefone ?? '';
      _cepController.text = widget.cliente!.cep ?? '';
      _enderecoController.text = widget.cliente!.endereco ?? '';
      _bairroController.text = widget.cliente!.bairro ?? '';
      _cidadeController.text = widget.cliente!.cidade ?? '';
      _ufController.text = widget.cliente!.uf ?? '';
    } else {
      _tipoSelecionado = TipoCliente.fisica;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
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
          id: widget.cliente?.id, // Mantém o ID se for edição
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          cpfCnpj: _cpfCnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          telefone: _telefoneController.text.trim().isNotEmpty ? _telefoneController.text.trim() : null,
          cep: _cepController.text.trim().isNotEmpty ? _cepController.text.trim() : null,
          endereco: _enderecoController.text.trim().isNotEmpty ? _enderecoController.text.trim() : null,
          bairro: _bairroController.text.trim().isNotEmpty ? _bairroController.text.trim() : null,
          cidade: _cidadeController.text.trim().isNotEmpty ? _cidadeController.text.trim() : null,
          uf: _ufController.text.trim().toUpperCase().isNotEmpty ? _ufController.text.trim().toUpperCase() : null,
          dataCadastro: widget.cliente?.dataCadastro ?? DateTime.now(),
          ativo: widget.cliente?.ativo ?? true,
        );

        bool sucesso = false;
        if (widget.cliente == null) {
          // Novo cliente
          if (await _controller.documentoExiste(novoCliente.cpfCnpj)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Já existe um cliente com este documento!'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          
          sucesso = (await _controller.adicionarCliente(novoCliente)) as bool;
        } else {
          // Edição de cliente existente
          if (await _controller.documentoExiste(novoCliente.cpfCnpj, novoCliente.id)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Já existe um cliente com este documento!'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          
          sucesso =  (await _controller.adicionarCliente(novoCliente))as bool;
        }

        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.cliente == null ? 'Cliente adicionado com sucesso!' : 'Cliente atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar cliente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar cliente: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarUF(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length != 2) {
      return 'UF deve ter 2 caracteres';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final telefoneRegex = RegExp(r'^[0-9]{10,11}$');
    final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (!telefoneRegex.hasMatch(apenasNumeros)) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
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
                    setState(() {
                      _tipoSelecionado = value;
                      // Limpa o campo CPF/CNPJ quando muda o tipo
                      _cpfCnpjController.clear();
                    });
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                decoration: InputDecoration(
                  labelText: _tipoSelecionado == TipoCliente.fisica ? 'CPF *' : 'CNPJ *',
                  border: const OutlineInputBorder(),
                  hintText: _tipoSelecionado == TipoCliente.fisica ? '000.000.000-00' : '00.000.000/0000-00',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o documento';
                  }
                  
                  // Remove espaços e caracteres especiais
                  final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                  
                  if (_tipoSelecionado == TipoCliente.fisica && cleanValue.length != 11) {
                    return 'CPF deve ter 11 dígitos';
                  }
                  if (_tipoSelecionado == TipoCliente.juridica && cleanValue.length != 14) {
                    return 'CNPJ deve ter 14 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validarEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  hintText: '(27) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
                validator: _validarTelefone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                        hintText: '00000-000',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanValue.length != 8) {
                            return 'CEP deve ter 8 dígitos';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _bairroController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
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
                        hintText: 'ES',
                      ),
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      validator: _validarUF,
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
                  child: Text(
                    isEdicao ? 'Atualizar Cliente' : 'Salvar Cliente',
                    style: const TextStyle(fontSize: 16),
                  ),
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
                          content: Text('Deseja realmente excluir o cliente "${widget.cliente!.nome}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );

                      if (confirmado == true && mounted) {
                        try {
                          final sucesso = await _controller.removerCliente(widget.cliente!.id!);
                          if (sucesso && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cliente excluído com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao excluir cliente'),
                                backgroundColor: Colors.red,
                              ),
                            );
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