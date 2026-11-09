import 'package:flutter/material.dart';

import '../models/product.dart';

/// Add / edit dialog. Returns the column values to send to Supabase,
/// or null if the user cancelled.
Future<Map<String, dynamic>?> showProductFormDialog(
  BuildContext context, {
  Product? product,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _ProductFormDialog(product: product),
  );
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({this.product});

  final Product? product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _category;
  late final TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p?.price.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '0');
    _category = TextEditingController(text: p?.category ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _category.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final category = _category.text.trim();
    final imageUrl = _imageUrl.text.trim();

    Navigator.pop(context, <String, dynamic>{
      'name': _name.text.trim(),
      'price': double.parse(_price.text.trim()),
      'stock': int.parse(_stock.text.trim()),
      'category': category.isEmpty ? null : category,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit product' : 'Add product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price (₱)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final parsed = double.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed < 0) return 'Enter a valid price';
                  return null;
                },
              ),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final parsed = int.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed < 0) return 'Enter a valid stock';
                  return null;
                },
              ),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _imageUrl,
                decoration:
                    const InputDecoration(labelText: 'Image URL (optional)'),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
