import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/core/network/dio_client.dart' show kBaseUrl; 
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../data/models/cart_item_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    return '$base$cleanUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("My Shopping Cart", 
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E), size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartInitial || (state is CartUpdated && state.items.isEmpty)) {
            return _buildEmptyCart();
          }

          if (state is CartUpdated) {
            Map<String, List<CartItemModel>> groupedItems = {};
            for (var item in state.items) {
              groupedItems.putIfAbsent(item.shopName, () => []).add(item);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: groupedItems.entries.map((entry) {
                      return _buildShopSection(context, entry.key, entry.value);
                    }).toList(),
                  ),
                ),
                _buildCheckoutSection(context, state.totalPrice),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildShopSection(BuildContext context, String shopName, List<CartItemModel> items) {
    bool isAllSelected = items.every((item) => item.isSelected);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  activeColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    for (var item in items) {
                      if (item.isSelected != val) {
                        context.read<CartCubit>().toggleSelection(item.product.id);
                      }
                    }
                  },
                ),
                const Icon(Icons.storefront_outlined, color: Color(0xFF1A237E), size: 20),
                const SizedBox(width: 8),
                Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildCartItem(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Checkbox(
            value: item.isSelected,
            activeColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => context.read<CartCubit>().toggleSelection(item.product.id),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _fullImageUrl(item.product.images.isNotEmpty ? item.product.images.first.url : ''),
              width: 75, height: 75, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Container(width: 75, height: 75, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold), 
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text("${item.product.price} JD", 
                  style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          _buildQtyControls(context, item),
        ],
      ),
    );
  }

  Widget _buildQtyControls(BuildContext context, CartItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            context.read<CartCubit>().removeFromCart(item.product.id);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _qtyBtn(Icons.remove, () => context.read<CartCubit>().decrementQuantity(item.product.id)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            _qtyBtn(Icons.add, () => context.read<CartCubit>().incrementQuantity(item.product.id)),
          ],
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1A237E)),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -4))]
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                Text("${total.toStringAsFixed(2)} JD", 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (total > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select items to checkout"))
                    );
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text("Confirm Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your cart is empty", 
            style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Add items to see them here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}