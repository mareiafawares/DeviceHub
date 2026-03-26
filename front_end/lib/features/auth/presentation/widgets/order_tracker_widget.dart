import 'package:flutter/material.dart';

class OrderTrackerWidget extends StatelessWidget {
  final String status;

  const OrderTrackerWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String s = status.trim().toLowerCase();

    if (s == 'canceled' || s == 'cancelled' || s == 'rejected') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "This order has been canceled",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    int currentStep = 0;
    if (s == 'pending') {
      currentStep = 0;
    } else if (s == 'confirmed' || s == 'processed' || s == 'preparing') {
      currentStep = 1;
    } else if (s == 'shipped' || s == 'on the way') {
      currentStep = 2;
    } else if (s == 'delivered' || s == 'done' || s == 'completed') {
      currentStep = 3;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(Icons.history, "Pending", currentStep >= 0, currentStep == 0),
          _buildLine(currentStep >= 1),
          _buildStep(Icons.inventory_2_outlined, "Confirmed", currentStep >= 1, currentStep == 1),
          _buildLine(currentStep >= 2),
          _buildStep(Icons.local_shipping_outlined, "Shipped", currentStep >= 2, currentStep == 2),
          _buildLine(currentStep >= 3),
          _buildStep(Icons.check_circle_outline, "Done", currentStep >= 3, currentStep == 3),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String label, bool isReached, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isReached ? Colors.green : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: isCurrent 
              ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)] 
              : [],
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
            color: isReached ? Colors.green[800] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isPassed) {
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: isPassed ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}