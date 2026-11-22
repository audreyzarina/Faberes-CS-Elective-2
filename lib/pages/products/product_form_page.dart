import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config.dart';
import '../../core/errors.dart';
import '../../models/product.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_helpers.dart';

/// Add / edit form (admin only). Pass [product] to edit; fields are pre-filled.
class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  int? _categoryId;
  XFile? _picked;
  Uint8List? _pickedBytes;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(2));
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _categoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _picked = file;
        _pickedBytes = bytes;
      });
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not open the photo library.', error: true);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(productControllerProvider);
    final existing = widget.product;

    try {
      var imageUrl = existing?.imageUrl;
      if (_picked != null) imageUrl = await controller.uploadImage(_picked!);

      final description = _description.text.trim();
      final draft = ProductDraft(
        name: _name.text.trim(),
        description: description.isEmpty ? null : description,
        price: double.parse(_price.text.trim()),
        stock: int.parse(_stock.text.trim()),
        categoryId: _categoryId!,
        imageUrl: imageUrl,
      );

      if (existing == null) {
        await controller.create(draft);
      } else {
        await controller.update(existing.id, draft);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(existing == null ? 'Product added.' : 'Product updated.')),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit product' : 'Add product')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _pickedBytes != null
                          ? Image.memory(_pickedBytes!, fit: BoxFit.cover)
                          : ProductImage(url: widget.product?.imageUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _pickedBytes != null || (widget.product?.imageUrl ?? '').isNotEmpty
                        ? 'Change image'
                        : 'Choose image',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: fieldDecoration('Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: fieldDecoration('Description (optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      decoration: fieldDecoration('Price (₱)'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Price is required';
                        final n = double.tryParse(value);
                        if (n == null) return 'Enter a number';
                        if (n < 0) return 'Must be 0 or more';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: fieldDecoration('Stock'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Stock is required';
                        final n = int.tryParse(value);
                        if (n == null) return 'Whole number only';
                        if (n < 0) return 'Must be 0 or more';
                        if (n > AppConfig.maxStock) return 'Max ${AppConfig.maxStock}';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categories.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        friendlyError(e),
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(categoriesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Card(
                      color: scheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Create a category first (Categories tab), then come back to add a product.',
                          style: TextStyle(color: scheme.onTertiaryContainer),
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<int>(
                    initialValue: list.any((c) => c.id == _categoryId) ? _categoryId : null,
                    decoration: fieldDecoration('Category'),
                    items: [
                      for (final c in list)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Choose a category' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save changes' : 'Add product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
