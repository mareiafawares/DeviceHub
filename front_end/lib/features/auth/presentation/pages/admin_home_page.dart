import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'admin_users_page.dart';
import 'admin_shop_requests_page.dart'; // تأكدي من وجود هذا الملف

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      // BlocListener لمراقبة أي أخطاء عامة تظهر في لوحة التحكم
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF1A237E),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Admin Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 60,
                        left: 25,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Welcome back,",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Maria Fawares",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.power_settings_new_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      // تسجيل الخروج والعودة لصفحة اللوجن
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "System Management",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.95,
                      children: [
                        // 1. Users Management
                        _buildModernItem(
                          context,
                          Icons.people_alt_rounded,
                          "Users",
                          "Manage Accounts",
                          const Color(0xFF6C5CE7),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminUsersPage()),
                          ),
                        ),
                        
                        // 2. Sellers & Shop Requests (الربط الجديد هنا)
                        _buildModernItem(
                          context,
                          Icons.store_mall_directory_rounded,
                          "Sellers",
                          "Shop Requests",
                          const Color(0xFF00B894),
                          () {
                            // جلب الطلبات من السيرفر أولاً
                            context.read<AuthCubit>().fetchPendingShops();
                            // الانتقال لصفحة عرض الطلبات
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminShopRequestsPage()),
                            );
                          },
                        ),

                        // 3. Products
                        _buildModernItem(
                          context,
                          Icons.inventory_2_rounded,
                          "Products",
                          "Item Catalog",
                          const Color(0xFFE17055),
                          () => print("Products Management"),
                        ),

                        // 4. Orders
                        _buildModernItem(
                          context,
                          Icons.local_shipping_rounded,
                          "Orders",
                          "Track Shipments",
                          const Color(0xFF0984E3),
                          () => print("Orders Management"),
                        ),

                        // 5. Complaints
                        _buildModernItem(
                          context,
                          Icons.report_problem_rounded,
                          "Complaints",
                          "User Issues",
                          const Color(0xFFD63031),
                          () => print("Complaints Management"),
                        ),

                        // 6. Statistics
                        _buildModernItem(
                          context,
                          Icons.analytics_rounded,
                          "Statistics",
                          "System Growth",
                          const Color(0xFF636E72),
                          () => print("Stats Tapped"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}