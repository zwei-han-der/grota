import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _itens = [];

  List<CartItem> get itens => List.unmodifiable(_itens);

  void adicionar(Product produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      _itens[index].quantidade++;
    } else {
      _itens.add(CartItem(produto: produto));
    }
    notifyListeners();
  }

  void remover(Product produto) {
    _itens.removeWhere((item) => item.produto.id == produto.id);
    notifyListeners();
  }

  void aumentarQuantidade(Product produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      _itens[index].quantidade++;
      notifyListeners();
    }
  }

  void diminuirQuantidade(Product produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      if (_itens[index].quantidade > 1) {
        _itens[index].quantidade--;
      } else {
        _itens.removeAt(index);
      }
      notifyListeners();
    }
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  double get total => _itens.fold(0, (soma, item) => soma + item.subtotal);
}
