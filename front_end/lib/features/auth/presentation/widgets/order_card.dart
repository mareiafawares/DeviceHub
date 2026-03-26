import 'package:flutter/material.dart';
import 'package:front_end/core/network/dio_client.dart' show kBaseUrl; 
import '../../data/models/order_model.dart';
import 'order_tracker_widget.dart'; 

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusUpdate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  String _getCorrectImageUrl(String? path) {
    if (path == null || path.isEmpty || path == "null") return '';
    if (path.startsWith('http')) return path;

    String baseUrl = kBaseUrl.endsWith('/') 
        ? kBaseUrl.substring(0, kBaseUrl.length - 1) 
        : kBaseUrl;
    
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${order.totalPrice.toStringAsFixed(2)} JD",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1),

            OrderTrackerWidget(status: order.status),
            const SizedBox(height: 20),

            _buildInfoRow(Icons.person_outline, "${order.fullName} - ${order.city}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, order.addressDetails),
            
            const Divider(height: 30),

            const Text(
              "Order Items:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 14),
            ),
            const SizedBox(height: 10),

            if (order.items.isEmpty)
              const Center(
                child: Text("No items found", style: TextStyle(color: Colors.red, fontSize: 12)),
              )
            else
              Column(
                children: order.items.map((item) {
                  final imageUrl = _getCorrectImageUrl(item.productImage);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50, height: 50, color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                "Qty: ${item.quantity} x ${item.priceAtPurchase.toStringAsFixed(2)} JD",
                                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${(item.quantity * item.priceAtPurchase).toStringAsFixed(2)} JD",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const Divider(height: 25),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onStatusUpdate,
                icon: const Icon(Icons.edit_road_rounded, size: 18),
                label: const Text("View / Update Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}