import 'package:flutter/material.dart';
import '../../controllers/pedido_controller.dart';
import '../../models/pedido_model.dart';
import 'components/cliente_selecao.dart';
import 'components/usuario_selecao.dart';
import 'components/item_lista.dart';
import 'components/pagamento_lista.dart';
import 'components/resumo_pedido.dart';

class CadastroPedidoPage extends StatefulWidget {
  final Pedido? pedido;
  final int? usuarioLogadoId;

  const CadastroPedidoPage({
    super.key,
    this.pedido,
    this.usuarioLogadoId,
  });

  @override
  State<CadastroPedidoPage> createState() => _CadastroPedidoPageState();
}

class _CadastroPedidoPageState extends State<CadastroPedidoPage> {
  final PedidoController _controller = PedidoController();
  final _formKey = GlobalKey<FormState>();
  
  late Pedido _pedido;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido ?? _resetPedido();
    if (widget.pedido == null && widget.usuarioLogadoId != null) {
      _pedido = _pedido.copyWith(idUsuario: widget.usuarioLogadoId!);
    }
  }

  Pedido _resetPedido() {
    return Pedido(
      id: 0,
      idCliente: 0,
      idUsuario: 0,
      totalPedido: 0,
      dataCriacao: DateTime.now(),
      itens: [],
      pagamentos: [],
    );
  }

  void _adicionarItem(PedidoItem item) {
    setState(() {
      final novosItens = List<PedidoItem>.from(_pedido.itens)..add(item);
      _pedido = _pedido.copyWith(
        itens: novosItens,
        totalPedido: _calcularTotal(novosItens),
      );
    });
  }

  void _removerItem(int index) async {
    final itemRemovido = _pedido.itens[index];
    
    try {
      setState(() {
        final novosItens = List<PedidoItem>.from(_pedido.itens)..removeAt(index);
        _pedido = _pedido.copyWith(
          itens: novosItens,
          totalPedido: _calcularTotal(novosItens),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover item: $e')),
      );
      setState(() {
        final novosItens = List<PedidoItem>.from(_pedido.itens)..add(itemRemovido);
        _pedido = _pedido.copyWith(
          itens: novosItens,
          totalPedido: _calcularTotal(novosItens),
        );
      });
    }
  }

  void _adicionarPagamento(PedidoPagamento pagamento) {
    setState(() {
      final novosPagamentos = List<PedidoPagamento>.from(_pedido.pagamentos)
        ..add(pagamento);
      _pedido = _pedido.copyWith(pagamentos: novosPagamentos);
    });
  }

  void _removerPagamento(int index) {
    setState(() {
      final novosPagamentos = List<PedidoPagamento>.from(_pedido.pagamentos)
        ..removeAt(index);
      _pedido = _pedido.copyWith(pagamentos: novosPagamentos);
    });
  }

  double _calcularTotal(List<PedidoItem> itens) {
    return itens.fold(0, (total, item) => total + item.totalItem);
  }

  void _atualizarCliente(int clienteId) {
    setState(() {
      _pedido = _pedido.copyWith(idCliente: clienteId);
    });
  }

  void _atualizarUsuario(int usuarioId) {
    setState(() {
      _pedido = _pedido.copyWith(idUsuario: usuarioId);
    });
  }

  Future<void> _salvarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pedido.idUsuario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um usuário antes de salvar!')),
      );
      return;
    }
    
    final isValid = await _controller.validarPedido(_pedido);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido inválido! Verifique itens e pagamentos')),
      );
      return;
    }

    try {
      if (_pedido.id > 0) {
        await _controller.atualizarPedidoCompleto(_pedido);
      } else {
        await _controller.criarPedidoCompleto(_pedido);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pedido.id > 0 ? 'Editar Pedido' : 'Novo Pedido'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              ClienteSelecao(
                onClienteSelecionado: _atualizarCliente,
                clienteIdInicial: _pedido.idCliente > 0 ? _pedido.idCliente : null,
              ),
              const SizedBox(height: 4),
              UsuarioSelecao(
                onUsuarioSelecionado: _atualizarUsuario,
                usuarioIdInicial: _pedido.idUsuario > 0 ? _pedido.idUsuario : null,
              ),
              const SizedBox(height: 4),
              ItemLista(
                itens: _pedido.itens,
                onRemoverItem: _removerItem,
                onAdicionarItem: _adicionarItem,
              ),
              const SizedBox(height: 4),
              PagamentoLista(
                pagamentos: _pedido.pagamentos,
                onRemoverPagamento: _removerPagamento,
                onAdicionarPagamento: _adicionarPagamento,
                totalPedido: _pedido.totalPedido,
              ),
              const SizedBox(height: 4),
              ResumoPedido(
                pedido: _pedido,
                onFinalizar: _salvarPedido,
              ),
            ],
          ),
        ),
      ),
    );
  }
}