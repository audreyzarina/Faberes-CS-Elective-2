import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_shop/models/product.dart';

void main() {
  test('Product.fromMap maps Supabase columns', () {
    final product = Product.fromMap({
      'id': 1,
      'name': 'Canvas Sneakers',
      'description': null,
      'price': 1299,
      'stock': 12,
      'category': 'Shoes',
      'image_url': null,
    });

    expect(product.id, 1);
    expect(product.name, 'Canvas Sneakers');
    expect(product.price, 1299.0);
    expect(product.stock, 12);
    expect(product.category, 'Shoes');
    expect(product.imageUrl, isNull);
  });
}
