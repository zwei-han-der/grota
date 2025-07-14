import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './add_product_screen.dart';

class AdminDashboardScaffold extends StatelessWidget {
  const AdminDashboardScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AdminDashboard(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 24, right: 24),
        child: PhysicalModel(
          color: Colors.white,
          elevation: 12,
          borderRadius: BorderRadius.circular(32),
          shadowColor: Colors.black26,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Color(0xFF780000), width: 2),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color(0xFF780000),
              unselectedItemColor: Colors.grey[500],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: 2, // Perfil/Admin
              onTap: (index) {
                if (index == 0) Navigator.pushReplacementNamed(context, '/', arguments: {'tab': 0});
                if (index == 1) Navigator.pushReplacementNamed(context, '/', arguments: {'tab': 1});
                if (index == 2) Navigator.pushReplacementNamed(context, '/', arguments: {'tab': 2});
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(FontAwesomeIcons.house, size: 28),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(FontAwesomeIcons.cartShopping, size: 28),
                  ),
                  label: 'Carrinho',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(FontAwesomeIcons.user, size: 28),
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<bool> _isAdmin(User? user) async {
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['role'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.usuario;
    return FutureBuilder<bool>(
      future: _isAdmin(user),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!) {
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/'));
          return const Scaffold();
        }
        return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Produtos da Grota - Admin'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductScreen()),
              );
              Provider.of<ProductService>(context, listen: false).carregarProdutos();
            },
          ),
        ],
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, child) {
          final produtos = productService.produtos;
          if (produtos.isEmpty) {
            productService.carregarProdutos();
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return AdminProductCard(produto: produto);
            },
          );
        },
      ),
    );
      },
    );
  }
}

class AdminProductCard extends StatelessWidget {
  final Product produto;
  const AdminProductCard({required this.produto, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: produto.imagens.isNotEmpty
            ? Image.network(
                produto.imagens.first,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(FontAwesomeIcons.image, size: 40, color: Colors.grey),
              )
            : const Icon(FontAwesomeIcons.image, size: 40, color: Colors.grey),
        title: Text(produto.nome),
        subtitle: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.penToSquare),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(produto: produto),
                  ),
                );
                Provider.of<ProductService>(context, listen: false).carregarProdutos();
              },
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.trash),
              onPressed: () {
                Provider.of<ProductService>(
                  context,
                  listen: false,
                ).removerProduto(produto.id);
              },
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(produto: produto),
            ),
          );
          Provider.of<ProductService>(context, listen: false).carregarProdutos();
        },
      ),
    );
  }
}
