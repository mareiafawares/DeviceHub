import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../cubit/product_cubit.dart';

class EditProductSheet extends StatefulWidget {
  final ProductModel product;
  final int shopId;
  final BuildContext? scaffoldContext;

  const EditProductSheet({
    super.key,
    required this.product,
    required this.shopId,
    this.scaffoldContext,
  });

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descController;
  late final TextEditingController _discountController;
  late String _selectedCategory;
  late String _selectedStatus;
  bool _isSubmitting = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
    _descController = TextEditingController(text: widget.product.description);
    _discountController = TextEditingController(
      text: widget.product.discountPrice?.toString() ?? '',
    );
    _selectedCategory = widget.product.category;
    _selectedStatus = widget.product.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationError = 'Enter product name');
      return;
    }
    final price = double.tryParse(_priceController.text);
    if (price == null || price < 0) {
      setState(() => _validationError = 'Enter a valid price');
      return;
    }
    setState(() {
      _validationError = null;
      _isSubmitting = true;
    });
    try {
      final productData = <String, dynamic>{
        'name': name,
        'price': price,
        'description': _descController.text.trim().isEmpty ? 'No description' : _descController.text.trim(),
        'stock_quantity': int.tryParse(_stockController.text) ?? 0,
        'category': _selectedCategory,
        'status': _selectedStatus,
      };
      final discount = double.tryParse(_discountController.text);
      if (discount != null && discount >= 0) {
        productData['discount_price'] = discount;
      }
      await context.read<ProductCubit>().updateProduct(widget.product.id, widget.shopId, productData);
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Product updated', isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      _showSnackBar(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim());
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    final ctx = widget.scaffoldContext;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Edit product",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            _buildField("Product name", "e.g. iPhone 15", Icons.shopping_bag_outlined, _nameController),
            _buildField("Description", "Describe your product...", Icons.description_outlined, _descController, maxLines: 3),
            Row(
              children: [
                Expanded(
                  child: _buildField("Price (JD)", "0.00", Icons.sell_outlined, _priceController, isNumber: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField("Stock", "0", Icons.inventory_2_outlined, _stockController, isNumber: true),
                ),
              ],
            ),
            _buildField("Discount price (optional)", "0.00", Icons.discount_outlined, _discountController, isNumber: true),
            const SizedBox(height: 12),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Electronics', 'Accessories', 'Laptops', 'Cameras', 'Tablets', 'General'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Available"),
                    value: "Available",
                    groupValue: _selectedStatus,
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Unavailable"),
                    value: "Unavailable",
                    groupValue: _selectedStatus,
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (_validationError != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _validationError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Save changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
