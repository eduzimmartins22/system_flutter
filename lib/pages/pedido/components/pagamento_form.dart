import 'package:flutter/material.dart';
import '../../../../models/pedido_model.dart';

class PagamentoForm extends StatefulWidget {
  final double totalPedido;
  final double totalPago;
  final Function(PedidoPagamento) onSubmit;

  const PagamentoForm({
    super.key,
    required this.totalPedido,
    required this.totalPago,
    required this.onSubmit,
  });

  @override
  State<PagamentoForm> createState() => _PagamentoFormState();
}

class _PagamentoFormState extends State<PagamentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Adicionar Pagamento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Campo de Valor
          TextFormField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Valor',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Informe o valor';
              final valor = double.tryParse(value);
              if (valor == null) return 'Valor inválido';
              if (valor <= 0) return 'Valor deve ser positivo';
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 24),
          
          // Informações de pagamento
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
                    const Text('Valor total:'),
                    Text('R\$${widget.totalPedido.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valor pago:'),
                    Text('R\$${widget.totalPago.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valor pendente:'),
                    Text(
                      'R\$${_calcularPendente().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _calcularPendente() < 0 ? Colors.red : Theme.of(context).primaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _salvarPagamento,
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calcularPendente() {
    final valor = double.tryParse(_valorController.text) ?? 0;
    return (widget.totalPedido - widget.totalPago) - valor;
  }

  void _salvarPagamento() {
    if (_formKey.currentState!.validate()) {
      final pagamento = PedidoPagamento(
        id: 0,
        idPedido: 0,
        valor: double.parse(_valorController.text),
      );
      widget.onSubmit(pagamento);
      Navigator.pop(context);
    }
  }
}