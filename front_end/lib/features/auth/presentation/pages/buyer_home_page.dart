import 'package:flutter/material.dart';
import 'package:front_end/features/auth/data/models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BuyerHomePage extends StatefulWidget {
  final Function(int) onShopSelected; 

  const BuyerHomePage({super.key, required this.onShopSelected});

  @override
  _BuyerHomePageState createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  List<ShopModel> allShops = [];
  bool isLoading = true;
  final String baseUrl = "http://192.168.1.11:8000";

  Future<void> fetchShops() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/shops/all'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          allShops = data.map((item) => ShopModel.fromJson(item)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildCategoryItem("All", Icons.store),
              _buildCategoryItem("Electronics", Icons.electric_bolt),
              _buildCategoryItem("Games", Icons.gamepad),
              _buildCategoryItem("Fashion", Icons.checkroom),
            ],
          ),
        ),
        Expanded(
          child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))) 
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: allShops.length,
                itemBuilder: (context, index) {
                  return _buildShopCard(allShops[index]);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        elevation: 2,
        avatar: Icon(icon, size: 18, color: const Color(0xFF1A237E)),
        label: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildShopCard(ShopModel shop) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => widget.onShopSelected(shop.id), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                "$baseUrl${shop.imageUrl}",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    shop.description ?? "Explore our latest products",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}