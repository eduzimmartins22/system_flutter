import 'package:flutter/material.dart';
import '../../../../models/pedido_model.dart';

class ResumoPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onFinalizar;

  const ResumoPedido({
    super.key,
    required this.pedido,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final totalPagamentos = pedido.pagamentos.fold(
      0.0, (sum, pag) => sum + pag.valor);
    final diferenca = pedido.totalPedido - totalPagamentos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Resumo do Pedido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Itens:'),
                Text('R\$${pedido.totalPedido.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pagamentos:'),
                Text('R\$${totalPagamentos.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diferença:',
                  style: TextStyle(
                    color: diferenca.abs() < 0.01 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'R\$${diferenca.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: diferenca.abs() < 0.01 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _podeFinalizar() ? onFinalizar : null,
                child: const Text('Finalizar Pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _podeFinalizar() {
    return pedido.itens.isNotEmpty &&
        pedido.pagamentos.isNotEmpty &&
        (pedido.totalPedido - pedido.pagamentos.fold(
          0.0, (sum, pag) => sum + pag.valor)).abs() < 0.01;
  }
}