import '../services/sync_usuarios_service.dart';

class SyncController {
  final SyncUsuariosService _syncUsuariosService = SyncUsuariosService();
  final String serverUrl;
  final Function(String)? onLog;

  SyncController(this.serverUrl, {this.onLog});

  Future<void> sincronizarDados() async {
    onLog?.call('Iniciando sincronização de usuários...');
    await _syncUsuariosService.sincronizar(serverUrl, onLog: onLog);
    onLog?.call('Sincronização de usuários concluída');
  }
}