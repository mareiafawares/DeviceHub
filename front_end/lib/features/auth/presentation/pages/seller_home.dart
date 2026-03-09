import 'package:flutter/material.dart';

class SellerHome extends StatelessWidget {
  const SellerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("لوحة تحكم البائع (Seller)")),
      body: const Center(child: Text("أهلاً بك أيها البائع! هنا يمكنك إضافة أجهزتك.")),
    );
  }
}