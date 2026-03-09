import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("متجر المشتري (Customer)")),
      body: const Center(child: Text("أهلاً بك أيها المشتري! هنا ستجد الأجهزة.")),
    );
  }
}