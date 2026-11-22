class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryId,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final int? categoryId;
  final DateTime createdAt;

  bool get inStock => stock > 0;

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: (m['id'] as num).toInt(),
        name: m['name'] as String,
        description: m['description'] as String?,
        price: (m['price'] as num?)?.toDouble() ?? 0,
        stock: (m['stock'] as num?)?.toInt() ?? 0,
        imageUrl: m['image_url'] as String?,
        categoryId: (m['category_id'] as num?)?.toInt(),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

/// The writable fields of a product (used for insert and update).
class ProductDraft {
  const ProductDraft({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
  });

  final String name;
  final String? description;
  final double price;
  final int stock;
  final int categoryId;
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'image_url': imageUrl,
      };
}

class ProductsResult {
  const ProductsResult({required this.items, required this.total});

  final List<Product> items;
  final int total;

  int totalPages(int pageSize) =>
      total == 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);
}

/// Browse filters: search, category, price range and the current page.
class ProductFilter {
  const ProductFilter({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.page = 0,
  });

  final String search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final int page;

  bool get isActive =>
      search.trim().isNotEmpty ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null;

  ProductFilter copyWith({
    String? search,
    int? categoryId,
    bool clearCategory = false,
    double? minPrice,
    double? maxPrice,
    bool clearPrice = false,
    int? page,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      page: page ?? this.page,
    );
  }
}
