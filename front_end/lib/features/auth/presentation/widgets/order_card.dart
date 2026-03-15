import 'package:flutter/material.dart';
import '../../data/models/order_model.dart'; 

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusUpdate;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order ID: #${order.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const Divider(height: 25, thickness: 1),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Customer ID: ${order.userId}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "Total Price: \$${order.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: onStatusUpdate,
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  "Update Order Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ويدجت صغير لعرض حالة الطلب بلون مخصص
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Shipped':
        color = Colors.blue;
        break;
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold, 
          fontSize: 12,
        ),
      ),
    );
  }
}