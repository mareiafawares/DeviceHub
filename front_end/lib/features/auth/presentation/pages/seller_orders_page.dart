import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/order_card.dart';

class SellerOrdersPage extends StatelessWidget {
  final int shopId;

  const SellerOrdersPage({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderCubit>()..fetchShopOrders(shopId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        appBar: AppBar(
          title: const Text(
            "Shop Management",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A237E),
          elevation: 0,
        ),
        body: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderStatusUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<OrderCubit>().fetchShopOrders(shopId);
            }
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message), 
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A237E)),
              );
            } 
            
            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                color: const Color(0xFF1A237E),
                onRefresh: () async => context.read<OrderCubit>().fetchShopOrders(shopId),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return OrderCard(
                      order: order,
                      onStatusUpdate: () {
                        _showStatusBottomSheet(context, order.id);
                      },
                    );
                  },
                ),
              );
            }
            return const Center(child: Text("Swipe down to see new orders"));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No orders for your shop yet.", 
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context, int orderId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Order Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _statusOption(context, orderId, "Confirmed", "Order is accepted and being prepared", Icons.thumb_up_alt_outlined, Colors.orange),
            _statusOption(context, orderId, "Shipped", "Order is with the driver / In the car", Icons.local_shipping_outlined, Colors.blue),
            _statusOption(context, orderId, "Delivered", "Order has reached the customer", Icons.check_circle_outline, Colors.green),
            const Divider(),
            _statusOption(context, orderId, "Canceled", "Reject or cancel this order", Icons.cancel_outlined, Colors.red),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(BuildContext context, int orderId, String status, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {
        context.read<OrderCubit>().updateOrderStatus(orderId, status);
        Navigator.pop(context);
      },
    );
  }
}