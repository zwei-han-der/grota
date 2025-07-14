class Product {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final List<String> imagens;
  final int estoque;

  Product({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagens,
    required this.estoque,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    List<String> imagens = [];
    if (map['imagens'] != null) {
      imagens = List<String>.from(map['imagens']);
    } else if (map['imagem'] != null) {
      imagens = [map['imagem']];
    }
    return Product(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      imagens: imagens,
      estoque: map['estoque'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagens': imagens,
      'estoque': estoque,
    };
  }
}
