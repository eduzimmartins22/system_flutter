import 'package:flutter/material.dart';
import '../../controllers/configuracao_controller.dart';
import '../../controllers/sync_controller.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final ConfiguracaoController _configuracaoController = ConfiguracaoController();
  String _serverLink = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  List<String> _syncLogs = [];

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

  void _addLog(String message) {
    setState(() {
      _syncLogs.add(message);
      // Limita o tamanho do log para evitar consumo excessivo de memória
      if (_syncLogs.length > 100) {
        _syncLogs.removeAt(0);
      }
    });
  }

  Future<void> _onPressSync() async {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
      _syncLogs.clear();
    });

    _addLog('Iniciando sincronização...');
    _addLog('Conectando ao servidor: $_serverLink');

    try {
      final syncController = SyncController(_serverLink, onLog: _addLog);
      await syncController.sincronizarDados();
      _addLog('Sincronização concluída com sucesso!');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronização concluída com sucesso')),
      );
    } catch (e) {
      _addLog('Erro durante a sincronização: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro durante a sincronização: $e')),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
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
                    onPressed: (_serverLink.isEmpty || _isSyncing) ? null : _onPressSync,
                    child: _isSyncing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 10),
                              Text('Sincronizando...'),
                            ],
                          )
                        : const Text('Sincronizar Banco de Dados'),
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
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _syncLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum log de sincronização disponível',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            reverse: true, // Mostra os logs mais recentes primeiro
                            itemCount: _syncLogs.length,
                            itemBuilder: (context, index) {
                              final log = _syncLogs.reversed.toList()[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  log,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}