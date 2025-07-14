import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  final CollectionReference produtosRef = FirebaseFirestore.instance.collection(
    'products',
  );

  List<Product> produtos = [];

Future<void> carregarProdutos() async {
  final snapshot = await produtosRef.get();
  produtos = snapshot.docs
      .map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
      .toList();
  notifyListeners();
}

  Future<void> adicionarProduto(Product produto) async {
    await produtosRef.add(produto.toMap());
    await carregarProdutos();
  }

  Future<void> atualizarProduto(Product produto) async {
    await produtosRef.doc(produto.id).update(produto.toMap());
    await carregarProdutos();
  }

  Future<void> removerProduto(String id) async {
    await produtosRef.doc(id).delete();
    await carregarProdutos();
  }
}
