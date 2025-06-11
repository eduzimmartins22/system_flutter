import 'package:flutter/material.dart';
import '../../controllers/pedido_controller.dart';
import '../../models/pedido_model.dart';
import 'cadastro_pedido.dart';

class ListaPedidosPage extends StatefulWidget {
  final int? userId;

  const ListaPedidosPage({super.key, this.userId});

  @override
  State<ListaPedidosPage> createState() => _ListaPedidosPageState();
}

class _ListaPedidosPageState extends State<ListaPedidosPage> {
  final PedidoController _controller = PedidoController();
  late Future<List<Pedido>> _futurePedidos;

  @override
  void initState() {
    super.initState();
    _futurePedidos = _controller.listarPedidosCompletos();
  }

  void _atualizarLista() {
    setState(() {
      _futurePedidos = _controller.listarPedidosCompletos();
    });
  }

  Widget _buildPedidoCard(BuildContext context, Pedido pedido) {
    // Formata a data para dd/mm/yyyy - hh:mm
    final dataFormatada = '${pedido.dataCriacao.day.toString().padLeft(2, '0')}/'
      '${pedido.dataCriacao.month.toString().padLeft(2, '0')}/'
      '${pedido.dataCriacao.year} - ${pedido.dataCriacao.hour.toString().padLeft(2, '0')}:'
      '${pedido.dataCriacao.minute.toString().padLeft(2, '0')}';
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirCadastroPedido(context, pedido: pedido),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cliente: ${pedido.idCliente}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataFormatada,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$${pedido.totalPedido.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _futurePedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado'));
          }

          final pedidos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return _buildPedidoCard(context, pedido);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCadastroPedido(context),
        icon: const Icon(Icons.add),
        label: const Text("Novo Pedido"),
      ),
    );
  }

  void _abrirCadastroPedido(BuildContext context, {Pedido? pedido}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPedidoPage(
          pedido: pedido,
          usuarioLogadoId: widget.userId,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _atualizarLista();
      }
    });
  }
}