import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filtrarProdutos(List<Product> produtos) {
    if (_search.trim().isEmpty) return produtos;
    final busca = removerAcentos(_search.toLowerCase());
    return produtos.where((p) {
      final nome = removerAcentos(p.nome.toLowerCase());
      final desc = removerAcentos(p.descricao.toLowerCase());
      return nome.contains(busca) || desc.contains(busca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF780000), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, color: Color(0xFF780000)),
                    hintText: 'Busca',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ProductService>(
                builder: (context, productService, child) {
                  final produtos = productService.produtos;
                  if (produtos.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      productService.carregarProdutos();
                    });
                  }
                  final produtosFiltrados = _filtrarProdutos(produtos);
                  return RefreshIndicator(
                    onRefresh: () => productService.carregarProdutos(),
                    color: const Color(0xFF780000),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Produtos da Grota',
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Encontre a melhor lenha para suas necessidades',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final produto = produtosFiltrados.isNotEmpty ? produtosFiltrados[index] : null;
                                if (produto != null) {
                                  return ProductCard(produto: produto);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                              childCount: produtosFiltrados.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product produto;
  const ProductCard({required this.produto, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // imagem do produto
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: produto.imagens.isNotEmpty
            ? Image.network(
                produto.imagens.first,
                      width: double.infinity,
                fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.image, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Imagem não disponível',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.image, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Imagem não disponível',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // nome do produto
                Text(
                  produto.nome,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // descrição
                Text(
                  produto.descricao,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // preço e botão
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF780000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // estoque
                        if (produto.estoque > 0) ...[
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.circleCheck, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Em estoque: ${produto.estoque}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.circleXmark, size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                'Fora de estoque',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    Consumer<AuthService>(
                      builder: (context, auth, child) {
                        if (auth.autenticado) {
                          return ElevatedButton.icon(
                            onPressed: produto.estoque > 0 ? () {
                              context.read<CartService>().adicionar(produto);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(FontAwesomeIcons.circleCheck, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('${produto.nome} adicionado ao carrinho'),
                                      ),
                                    ],
                                  ),
                                  action: SnackBarAction(
                                    label: 'Desfazer',
                                    textColor: Colors.white,
          onPressed: () {
                                      context.read<CartService>().remover(produto);
                                    },
                                  ),
                                ),
                              );
                            } : null,
                            icon: const Icon(FontAwesomeIcons.cartPlus),
                            label: const Text('Adicionar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: produto.estoque > 0 
                                  ? const Color(0xFF780000)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else {
                          return ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            icon: const Icon(FontAwesomeIcons.rightToBracket),
                            label: const Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF780000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
