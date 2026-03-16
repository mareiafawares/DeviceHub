import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/product_cubit.dart';

class AddProductSheet extends StatefulWidget {
  final int shopId;
  const AddProductSheet({super.key, required this.shopId});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _selectedCategory = 'Electronics';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
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
              "Product Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const Text(
              "Fill in the information to list your item",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => _imageFile = File(picked.path));
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2D43A6).withOpacity(0.3), width: 2),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_enhance_rounded, color: Color(0xFF2D43A6), size: 35),
                            SizedBox(height: 8),
                            Text("Add Photo", style: TextStyle(color: Color(0xFF2D43A6), fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildModernField(
              label: "Product Name",
              hint: "e.g. iPhone 15 Pro",
              icon: Icons.shopping_bag_outlined,
              controller: _nameController,
            ),
            _buildModernField(
              label: "Description",
              hint: "Describe your product...",
              icon: Icons.description_outlined,
              controller: _descController,
              maxLines: 3,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildModernField(
                    label: "Price (\$)",
                    hint: "0.00",
                    icon: Icons.sell_outlined,
                    isNumber: true,
                    controller: _priceController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildModernField(
                    label: "Stock Quantity",
                    hint: "Qty",
                    icon: Icons.inventory_2_outlined,
                    isNumber: true,
                    controller: _stockController,
                  ),
                ),
              ],
            ),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Electronics', 'Accessories', 'Laptops', 'Cameras', 'Tablets'].map((cat) {
                  bool isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2D43A6) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D43A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {
                  if (_nameController.text.isNotEmpty && 
                      _priceController.text.isNotEmpty && 
                      _imageFile != null) {
                    
                    final Map<String, dynamic> productData = {
                      "name": _nameController.text,
                      "price": double.tryParse(_priceController.text) ?? 0.0,
                      "description": _descController.text.trim().isEmpty 
                          ? "No description provided" 
                          : _descController.text,
                      "imageUrl": _imageFile!.path,
                      "stockQuantity": int.tryParse(_stockController.text) ?? 0,
                      "category": _selectedCategory,
                    };

                    context.read<ProductCubit>().addProduct(widget.shopId, productData);
                    Navigator.pop(context);
                  } else {
                    String error = "Please fill name, price and add a photo";
                    if (_imageFile == null) error = "Please select a product image";
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                child: const Text(
                  "List Product Now",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    required TextEditingController controller,
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
              borderSide: const BorderSide(color: Color(0xFF2D43A6), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}