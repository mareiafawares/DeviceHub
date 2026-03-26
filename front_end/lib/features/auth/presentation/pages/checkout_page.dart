import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/core/network/dio_client.dart' show kBaseUrl;
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart'; 
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import 'my_orders_page.dart'; 

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    return '$base${url.startsWith('/') ? url.substring(1) : url}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          context.read<CartCubit>().clearCart();
          _showSuccessSheet(context);
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          title: const Text("Confirm Order", 
            style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            if (cartState is! CartUpdated || cartState.items.where((i) => i.isSelected).isEmpty) {
              return const Center(child: Text("No items selected"));
            }

            final selectedItems = cartState.items.where((item) => item.isSelected).toList();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Review Your Items"),
                          const SizedBox(height: 10),
                          ...selectedItems.map((item) => _buildProductCard(context, item)).toList(),
                          
                          const SizedBox(height: 25),
                          _buildSectionTitle("Shipping Details"),
                          const SizedBox(height: 10),
                          
                          _buildInputCard([
                            _buildTextField(controller: _nameController, label: "Full Name", icon: Icons.person_outline),
                            _buildTextField(controller: _phoneController, label: "Phone Number", icon: Icons.phone_android, isPhone: true),
                            _buildTextField(controller: _cityController, label: "City / Area", icon: Icons.location_city),
                            _buildTextField(controller: _addressController, label: "Detailed Address", icon: Icons.map_outlined, maxLines: 2),
                            _buildTextField(controller: _notesController, label: "Delivery Notes", icon: Icons.edit_note, isLast: true),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomSummary(cartState.totalPrice, selectedItems),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onPlaceOrder(double total, List<CartItemModel> items) {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      int currentUserId = 0;
      
      if (authState is AuthSuccess) {
        currentUserId = authState.userId ?? authState.user.id;
      }

      final orderItems = items.map((item) {
        final imgUrl = item.product.images.isNotEmpty ? item.product.images.first.url : '';
        return OrderItemModel(
          productId: item.product.id,
          quantity: item.quantity,
          priceAtPurchase: double.parse(item.product.price.toString()),
          productName: item.product.name, 
          productImage: _fullImageUrl(imgUrl),
        );
      }).toList();

      final orderRequest = OrderModel(
        id: 0, 
        userId: currentUserId, 
        shopId: items.isNotEmpty ? (items.first.product.shopId ?? 1) : 1,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        city: _cityController.text,
        addressDetails: _addressController.text,
        deliveryNotes: _notesController.text,
        totalPrice: total,
        status: 'Pending',
        createdAt: DateTime.now(),
        items: orderItems,
      );

      context.read<OrderCubit>().placeOrder(orderRequest);
    }
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text("Order Placed Successfully!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Text(
                "Your order has been received. You can track its progress now.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),
            
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(sheetContext); 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                  );
                },
                child: const Text("TRACK MY ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("Back to Home", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(double total, List<CartItemModel> selectedItems) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payment", style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text("${total.toStringAsFixed(2)} JD", 
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: state is OrderLoading ? null : () => _onPlaceOrder(total, selectedItems),
                    child: state is OrderLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("PLACE ORDER NOW", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, CartItemModel item) {
    final imgUrl = item.product.images.isNotEmpty ? item.product.images.first.url : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _fullImageUrl(imgUrl),
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60, height: 60, color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Qty: ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text("${(double.tryParse(item.product.price.toString()) ?? 0 * item.quantity).toStringAsFixed(2)} JD",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPhone = false,
    bool isLast = false,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
        ),
        if (!isLast) Divider(color: Colors.grey[100], height: 1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}