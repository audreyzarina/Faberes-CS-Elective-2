class OrderItem {
  const OrderItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final int id;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        id: (m['id'] as num).toInt(),
        productId: (m['product_id'] as num?)?.toInt(),
        productName: (m['product_name'] as String?) ?? 'Removed product',
        unitPrice: (m['unit_price'] as num).toDouble(),
        quantity: (m['quantity'] as num).toInt(),
      );
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.status,
    required this.total,
    required this.items,
    this.customerName,
    this.customerEmail,
  });

  final int id;
  final DateTime createdAt;
  final String userId;
  final String status;
  final double total;
  final List<OrderItem> items;
  final String? customerName;
  final String? customerEmail;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  AppOrder withCustomer({String? name, String? email}) => AppOrder(
        id: id,
        createdAt: createdAt,
        userId: userId,
        status: status,
        total: total,
        items: items,
        customerName: name,
        customerEmail: email,
      );

  factory AppOrder.fromMap(Map<String, dynamic> m) {
    final items = ((m['order_items'] as List?) ?? const [])
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return AppOrder(
      id: (m['id'] as num).toInt(),
      createdAt: DateTime.parse(m['created_at'] as String),
      userId: m['user_id'] as String,
      status: (m['status'] as String?) ?? 'done',
      total: (m['total'] as num?)?.toDouble() ?? 0,
      items: items,
    );
  }
}

class PlacedOrder {
  const PlacedOrder({required this.orderId, required this.total});

  final int orderId;
  final double total;
}

const List<String> kOrderStatuses = ['pending', 'done', 'cancelled'];
