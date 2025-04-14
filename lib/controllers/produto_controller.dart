import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/produto_model.dart';

class ProdutoController {
  static const _produtosKey = 'lista_produtos';
  List<Produto> _produtos = [];

  Future<void> _carregarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_produtosKey);
    
    if (jsonString != null) {
      try {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        _produtos = jsonList.map((json) => Produto.fromJson(json)).toList();
      } catch (e) {
        _produtos = [];
      }
    } else {
      _produtos = [];
    }
  }

  Future<void> _salvarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _produtos.map((produto) => produto.toJson()).toList();
    await prefs.setString(_produtosKey, json.encode(jsonList));
  }

  Future<List<Produto>> getProdutos() async {
    await _carregarLista(); // Sempre recarrega os dados mais recentes
    return _produtos.toList();
  }

  Future<int> adicionarProduto(Produto produto) async {
    await _carregarLista();
    
    // Corrigido a verificação de ID duplicado
    if (_produtos.any((p) => p.id == produto.id)) {
      final novoProduto = produto.copyWith(id: _gerarNovoId());
      _produtos.add(novoProduto);
    } else {
      _produtos.add(produto);
    }
    
    await _salvarLista();
    return produto.id;
  }

  Future<bool> atualizarProduto(Produto produto) async {
    await _carregarLista();
    
    final index = _produtos.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _produtos[index] = produto;
      await _salvarLista();
      return true;
    }
    return false;
  }

  Future<bool> removerProduto(int id) async {
    await _carregarLista();
    
    final initialLength = _produtos.length;
    _produtos.removeWhere((produto) => produto.id == id);
    final removed = initialLength != _produtos.length;
    
    if (removed) {
      await _salvarLista();
    }
    return removed;
  }

  int _gerarNovoId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}