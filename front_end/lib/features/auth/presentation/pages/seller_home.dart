import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/cubit/product_cubit.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/auth/presentation/pages/products_page.dart';
import 'package:front_end/features/auth/presentation/pages/seller_orders_page.dart';
import 'package:front_end/features/auth/presentation/widgets/seller_stat_card.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/create_shop_dialog.dart';
import '../../data/models/user_model.dart';

class SellerHomePage extends StatefulWidget {
  final int userId;
  final String username;

  const SellerHomePage({super.key, required this.userId, required this.username});

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
      drawer: _buildDrawer(context),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Business Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          UserModel? user;
          if (state is AuthSuccess) user = state.user;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AuthCubit>().refreshUserData(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 25),
                _buildStatsRow(user),
                const SizedBox(height: 30),
                const Text(
                  "My Stores",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 15),
                
                if (user.shops.isEmpty)
                  _buildEmptyState()
                else
                  ...user.shops.map((shop) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: shop.isApproved
                            ? _buildShopCard(shop)
                            : _buildPendingCard(shop),
                      )).toList(),

                _buildAddShopButton(),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome, ${widget.username} 👋",
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Manage your business and track orders",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SellerStatCard(
            title: "Stores",
            value: user.shops.length.toString(),
            icon: Icons.storefront,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          const SellerStatCard(
            title: "Orders",
            value: "0",
            icon: Icons.shopping_cart_outlined,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          const SellerStatCard(
            title: "Revenue",
            value: "0 JD",
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(ShopModel shop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (shop.imageUrl != null && shop.imageUrl!.isNotEmpty)
                        ? NetworkImage(shop.imageUrl!)
                        : null,
                    child: (shop.imageUrl == null || shop.imageUrl!.isEmpty)
                        ? Text(
                            shop.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  shop.description ?? "No description available for this store.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<ProductCubit>(),
                                child: ProductsPage(shopId: shop.id),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        label: const Text("Products"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerOrdersPage(shopId: shop.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined, size: 18),
                        label: const Text("Orders"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  "Under Review by Admin",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddShopButton() {
    return OutlinedButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => CreateShopDialog(
          userId: widget.userId,
          ownerName: widget.username,
        ),
      ),
      icon: const Icon(Icons.add_business_rounded),
      label: const Text("Register New Store"),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("No stores found.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.username.isNotEmpty ? widget.username[0].toUpperCase() : "U",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
            accountName: Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("Verified Seller"),
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Profile"),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}