class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.category,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      category: map['category'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }
}
