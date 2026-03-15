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
        appBar: AppBar(
          title: const Text("Manage Shop Orders"),
          centerTitle: true,
        ),
        body: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderStatusUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              context.read<OrderCubit>().fetchShopOrders(shopId);
            }
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return const Center(
                  child: Text("No orders found for this shop."),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<OrderCubit>().fetchShopOrders(shopId),
                child: ListView.builder(
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return OrderCard(
                      order: order,
                      onStatusUpdate: () {
                        _showStatusDialog(context, order.id);
                      },
                    );
                  },
                ),
              );
            }
            return const Center(child: Text("Pull down to refresh orders"));
          },
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Update Status"),
        content: const Text("Select the current status of this order:"),
        actions: [
          _statusButton(context, dialogContext, orderId, "Shipped", Colors.blue),
          _statusButton(context, dialogContext, orderId, "Delivered", Colors.green),
          _statusButton(context, dialogContext, orderId, "Canceled", Colors.red),
        ],
      ),
    );
  }

  Widget _statusButton(BuildContext context, BuildContext dialogContext, int orderId, String status, Color color) {
    return TextButton(
      onPressed: () {
        context.read<OrderCubit>().updateOrderStatus(orderId, status);
        Navigator.pop(dialogContext);
      },
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}