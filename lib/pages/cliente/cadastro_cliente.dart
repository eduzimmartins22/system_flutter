import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistem_flutter/controllers/cliente_controller.dart';
import 'package:sistem_flutter/models/cliente_model.dart'; // Adicione se não tiver

// === CadastroClientePage ===
class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final ClienteController _controller = ClienteController();
  late Future<List<Cliente>> _futureClientes;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

void _carregarClientes() {
    setState(() {
      _futureClientes = _controller.getClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Cliente')),
      body: FutureBuilder<List<Cliente>>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }

          final clientes = snapshot.data!;
          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                title: Text(cliente.nome),
                subtitle: Text(cliente.email ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

// === BuscaCepWidget ===
class BuscaCepWidget extends StatefulWidget {
  final TextEditingController cepController;
  final TextEditingController enderecoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController ufController;
  final String? labelText;
  final String? hintText;

  const BuscaCepWidget({
    Key? key,
    required this.cepController,
    required this.enderecoController,
    required this.bairroController,
    required this.cidadeController,
    required this.ufController,
    this.labelText = 'CEP',
    this.hintText = '00000-000',
  }) : super(key: key);

  @override
  State<BuscaCepWidget> createState() => _BuscaCepWidgetState();
}

class _BuscaCepWidgetState extends State<BuscaCepWidget> {
  final ClienteController _controller = ClienteController();
  bool _carregando = false;

  Future<void> _buscarCep() async {
    final cep = widget.cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP deve ter 8 dígitos'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final endereco = await _controller.buscarEnderecoPorCep(cep);

      widget.enderecoController.text = endereco['logradouro'] ?? '';
      widget.bairroController.text = endereco['bairro'] ?? '';
      widget.cidadeController.text = endereco['cidade'] ?? '';
      widget.ufController.text = endereco['uf'] ?? '';
      widget.cepController.text = endereco['cep'] ?? cep;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Endereço preenchido automaticamente!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro ao buscar CEP: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: widget.cepController,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
              hintText: widget.hintText,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            onFieldSubmitted: (_) => _buscarCep(),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _carregando ? null : _buscarCep,
            icon: _carregando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search, size: 20),
            label: Text(
              _carregando ? 'Buscando...' : 'Buscar',
              style: const TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// === BuscaCepIconWidget ===
class BuscaCepIconWidget extends StatefulWidget {
  final TextEditingController cepController;
  final Function(Map<String, String>) onEnderecoEncontrado;
  final VoidCallback? onError;

  const BuscaCepIconWidget({
    Key? key,
    required this.cepController,
    required this.onEnderecoEncontrado,
    this.onError,
  }) : super(key: key);

  @override
  State<BuscaCepIconWidget> createState() => _BuscaCepIconWidgetState();
}

class _BuscaCepIconWidgetState extends State<BuscaCepIconWidget> {
  final ClienteController _controller = ClienteController();
  bool _carregando = false;

  Future<void> _buscarCep() async {
    final cep = widget.cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP deve ter 8 dígitos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final endereco = await _controller.buscarEnderecoPorCep(cep);
      widget.onEnderecoEncontrado(endereco);
    } catch (e) {
      widget.onError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar CEP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _carregando ? null : _buscarCep,
      icon: _carregando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search),
      tooltip: 'Buscar endereço pelo CEP',
    );
  }
}
