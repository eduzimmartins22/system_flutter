import 'package:flutter/material.dart';
import '../../controllers/configuracao_controller.dart';

class ConfiguracaoPage extends StatefulWidget {
  const ConfiguracaoPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracaoPage> createState() => _ConfiguracaoPageState();
}

class _ConfiguracaoPageState extends State<ConfiguracaoPage> {
  final TextEditingController _controller = TextEditingController();
  final ConfiguracaoController _controllerConfig = ConfiguracaoController();

  @override
  void initState() {
    super.initState();
    _loadServerLink();
  }

  Future<void> _loadServerLink() async {
    final link = await _controllerConfig.carregarLink();
    setState(() {
      _controller.text = link;
    });
  }

  Future<void> _saveServerLink() async {
    await _controllerConfig.salvarLink(_controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link do servidor salvo!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuração')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link do Servidor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _saveServerLink,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
