import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AdminShopRequestsPage extends StatefulWidget {
  const AdminShopRequestsPage({super.key});

  @override
  State<AdminShopRequestsPage> createState() => _AdminShopRequestsPageState();
}

class _AdminShopRequestsPageState extends State<AdminShopRequestsPage> {
  
  @override
  void initState() {
    super.initState();
    // طلب البيانات من السيرفر فور تشغيل الصفحة لكي لا تظل عالقة
    context.read<AuthCubit>().fetchPendingShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text("Shop Requests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: () => context.read<AuthCubit>().fetchPendingShops(),
          )
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ShopApprovalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // حالة التحميل
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // حالة نجاح التحميل وعرض القائمة
          if (state is PendingShopsLoaded) {
            if (state.shops.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      "No pending requests found.",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().fetchPendingShops(),
                      child: const Text("Check Again"),
                    )
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // تنفيذ عملية التحديث عند سحب الشاشة للأسفل
                await context.read<AuthCubit>().fetchPendingShops();
              },
              child: ListView.builder(
                // physics تضمن أن السحب للأسفل يعمل حتى لو كانت الشاشة فارغة أو العناصر قليلة
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15),
                itemCount: state.shops.length,
                itemBuilder: (context, index) {
                  final shop = state.shops[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.store, color: Color(0xFF1A237E)),
                      ),
                      title: Text(
                        shop['shop_name'] ?? 'Unknown Shop',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(shop['shop_description'] ?? 'No description provided'),
                          const SizedBox(height: 5),
                          Text("Owner ID: ${shop['id']}", 
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // زر الرفض
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _confirmAction(context, shop['id'], false),
                          ),
                          // زر القبول
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _confirmAction(context, shop['id'], true),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // في حالة البداية أو حدوث شيء غير متوقع
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Unable to load requests."),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().fetchPendingShops(),
                  child: const Text("Try Again"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // دالة لإظهار تأكيد قبل القبول أو الرفض
  void _confirmAction(BuildContext context, int userId, bool approve) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(approve ? "Approve Shop" : "Reject Request"),
        content: Text("Are you sure you want to ${approve ? 'approve' : 'reject'} this seller?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // تنفيذ العملية من خلال الـ Cubit
              context.read<AuthCubit>().approveOrRejectShop(userId: userId, approve: approve);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            child: Text(approve ? "Approve" : "Reject"),
          ),
        ],
      ),
    );
  }
}