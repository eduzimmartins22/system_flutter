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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _serverLink.isEmpty
                        ? null
                        : () {
                            // Lógica de sincronização será implementada futuramente
                          },
                    child: const Text('Sincronizar Banco de Dados'),
                  ),
                  if (_serverLink.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Configure o link do servidor nas configurações',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}