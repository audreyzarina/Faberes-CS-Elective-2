class ShopCategory {
  const ShopCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory ShopCategory.fromMap(Map<String, dynamic> m) =>
      ShopCategory(id: (m['id'] as num).toInt(), name: m['name'] as String);
}
