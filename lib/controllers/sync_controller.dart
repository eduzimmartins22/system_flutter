import '../services/sync_produtos_service.dart';
import '../services/sync_usuarios_service.dart';
import '../services/sync_clientes_service.dart';
import '../services/sync_pedidos_service.dart';

class SyncController {
  final SyncUsuariosService _syncUsuariosService = SyncUsuariosService();
  final SyncProdutosService _syncProdutosService = SyncProdutosService();
  final SyncClientesService _syncClientesService = SyncClientesService();
  final SyncPedidosService _syncPedidosService = SyncPedidosService();

  final String serverUrl;
  final Function(String)? onLog;

  SyncController(this.serverUrl, {this.onLog});

  Future<void> sincronizarDados() async {
    await _syncUsuariosService.sincronizar(serverUrl, onLog: onLog);
    await _syncProdutosService.sincronizar(serverUrl, onLog: onLog);
    await _syncClientesService.sincronizar(serverUrl, onLog: onLog);
    await _syncPedidosService.sincronizar(serverUrl, onLog: onLog);
  }
}