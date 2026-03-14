import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/cubit/product_cubit.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/auth/presentation/pages/products_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/create_shop_dialog.dart';
import '../../data/models/user_model.dart';

class SellerHomePage extends StatefulWidget {
  final int shopId;
  final int userId;
  final String username;

  const SellerHomePage({super.key, required this.userId, required this.username,required this.shopId});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().refreshUserData(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Seller Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ShopRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("New request sent successfully!"), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          UserModel? user;
          if (state is AuthSuccess) user = state.user;

          if (user == null) return const Center(child: CircularProgressIndicator());

          return RefreshIndicator(
            onRefresh: () => context.read<AuthCubit>().refreshUserData(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Text(
                  "Welcome, ${widget.username} 👋",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text("Your business activities at a glance", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

               
                if (user.shops.isEmpty)
                  const Center(child: Text("No shops registered yet.")),
                
               
                ...user.shops.map((shop) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: shop.isApproved 
                        ? _buildModernShopCard(context, shop) 
                        : _buildPendingStatusCard(shop),    
                  );
                }).toList(),

                const SizedBox(height: 10),

                // زر إضافة متجر جديد يظهر دائماً في الأسفل
                _buildAddAnotherShopButton(context),
                
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

 
  Widget _buildModernShopCard(BuildContext context, ShopModel shop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("VERIFIED SHOP", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                  onPressed: () => _confirmDelete(context, shop.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(shop.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(shop.description ?? "No description", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
           onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: context.read<ProductCubit>(),
        child: ProductsPage(shopId: widget.shopId),
      ),
    ),
  );
},
child: const Text("Manage Products"),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildPendingStatusCard(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${shop.name} (Pending)", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("This shop is being reviewed by the admin.", style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAnotherShopButton(BuildContext context) {
    return InkWell(
      onTap: () => _showCreateShopForm(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.add_business_rounded, color: Theme.of(context).primaryColor.withOpacity(0.5), size: 35),
            const SizedBox(height: 10),
            const Text("Register New Shop Unit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int shopId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Do you want to delete this shop?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().deleteShop(shopId);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateShopForm(BuildContext context) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => CreateShopDialog(userId: widget.userId));
  }
}