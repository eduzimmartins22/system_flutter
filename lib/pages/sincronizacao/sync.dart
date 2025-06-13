import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/configuracao_controller.dart';
import '../../controllers/sync_controller.dart';

const int maxLogLines = 100;

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final ConfiguracaoController _configuracaoController = ConfiguracaoController();
  String _serverLink = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  List<String> _syncLogs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarLinkServidor();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      if (_syncLogs.length > maxLogLines) {
        _syncLogs.removeAt(0);
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
    } catch (e) {
      _addLog('Erro durante a sincronização: $e');
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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: _serverLink.isEmpty
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                      foregroundColor: _serverLink.isEmpty
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.white,
                    ),
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
                        : const Text('Sincronizar com Servidor'),
                  ),
                ),
                if (_serverLink.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Configure o link do servidor nas configurações',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _syncLogs.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Nenhum log de sincronização disponível',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                    left: 16.0,
                                    right: 16.0,
                                  ),
                                  itemCount: _syncLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = _syncLogs.reversed.toList()[index];
                                    final lowerLog = log.toLowerCase();
                                    final isError = lowerLog.contains('erro');
                                    final isSuccess = lowerLog.contains('sucesso');
                                    
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 0.0,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: isError 
                                              ? Colors.red[50]
                                              : isSuccess
                                                  ? Colors.green[50]
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          log,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'RobotoMono',
                                            color: isError 
                                                ? Colors.red[700]
                                                : isSuccess
                                                    ? Colors.green[700]
                                                    : Colors.grey[800],
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (_syncLogs.isNotEmpty)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  final allLogs = _syncLogs.join('\n');
                                  Clipboard.setData(ClipboardData(text: allLogs));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Logs copiados para a área de transferência'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}