import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // طلب البيانات عند فتح الصفحة عبر الـ Cubit
    context.read<AuthCubit>().fetchAllUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text("Manage Users",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AuthCubit>().fetchAllUsers(),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Buyers", icon: Icon(Icons.shopping_bag)),
            Tab(text: "Sellers", icon: Icon(Icons.storefront)),
          ],
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsersLoaded) {
            final buyers = state.users.where((u) => u['role'] == 'customer').toList();
            final sellers = state.users.where((u) => u['role'] == 'seller').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(buyers, "No buyers found"),
                _buildUserList(sellers, "No sellers found"),
              ],
            );
          }

          if (state is AuthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().fetchAllUsers(),
                      child: const Text("Try Again"),
                    )
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("Loading users..."));
        },
      ),
    );
  }

  Widget _buildUserList(List<dynamic> filteredUsers, String emptyMessage) {
    if (filteredUsers.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
    );
  }

  Widget _buildUserCard(dynamic user) {
    bool isSeller = user['role'] == 'seller';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isSeller ? Colors.teal.shade50 : Colors.indigo.shade50,
          child: Icon(isSeller ? Icons.storefront : Icons.person,
              color: isSeller ? Colors.teal : Colors.indigo),
        ),
        title: Text(user['username'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user['email'] ?? 'No Email'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            // ملاحظة: دالة الحذف يجب إضافتها في الـ Cubit أيضاً إذا أردتِ تفعيلها
            _showSnackBar("Delete functionality is currently disabled");
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}