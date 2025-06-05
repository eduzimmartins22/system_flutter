import 'package:flutter/material.dart';
import 'pagamento_form.dart';
import '../../../../models/pedido_model.dart';

class PagamentoLista extends StatelessWidget {
  final List<PedidoPagamento> pagamentos;
  final Function(int) onRemoverPagamento;
  final Function(PedidoPagamento) onAdicionarPagamento;
  final double totalPedido;

  const PagamentoLista({
    super.key,
    required this.pagamentos,
    required this.onRemoverPagamento,
    required this.onAdicionarPagamento,
    required this.totalPedido,
  });

  @override
  Widget build(BuildContext context) {
    final totalPagamentos = pagamentos.fold<double>(
        0, (sum, pag) => sum + pag.valor);
    final diferenca = totalPedido - totalPagamentos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pagamentos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _mostrarFormularioPagamento(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (pagamentos.isEmpty)
              const Center(child: Text('Nenhum pagamento adicionado'))
            else
              Column(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: pagamentos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pagamento = entry.value;
                    return ListTile(
                      title: Text('Pagamento #${index + 1}'),
                      subtitle: Text(
                        'R\$${pagamento.valor.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onRemoverPagamento(index),
                      ),
                    );
                  }).toList(),
                  color: Colors.grey.shade300,
                ).toList(),
              ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pedido:'),
                      Text('R\$${totalPedido.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pagamentos:'),
                      Text('R\$${totalPagamentos.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioPagamento(BuildContext context) {
    final totalPagamentos = pagamentos.fold<double>(0, (sum, pag) => sum + pag.valor);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: PagamentoForm(
                totalPedido: totalPedido,
                totalPago: totalPagamentos, // Adicionamos este novo parâmetro
                onSubmit: onAdicionarPagamento,
              ),
            ),
          ),
        ),
      ),
    );
  }
}