import 'package:flutter/material.dart';
import '../../controllers/configuracao_controller.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final ConfiguracaoController _configuracaoController = ConfiguracaoController();
  String _serverLink = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLinkServidor();
  }

  Future<void> _carregarLinkServidor() async {
    final link = await _configuracaoController.carregarLink();
    setState(() {
      _serverLink = link;
      _isLoading = false;
    });
  }

  void _onPressSync() {
    // Aqui você pode adicionar lógica de sincronização posteriormente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronização iniciada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _serverLink.isEmpty ? null : _onPressSync,
                    child: const Text('Sincronizar Banco de Dados'),
                  ),
                ),
                if (_serverLink.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Configure o link do servidor nas configurações',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
