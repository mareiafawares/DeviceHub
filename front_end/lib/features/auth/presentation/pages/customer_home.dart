import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../widgets/product_card.dart';
import 'product_details_page.dart';

class CustomerHomePage extends StatefulWidget {
 
  final int shopId;
  const CustomerHomePage({super.key, required this.shopId});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  @override
  void initState() {
    super.initState();
   
    context.read<ProductCubit>().fetchProductsByShop(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userName = "User";
        if (authState is AuthSuccess) {
          userName = authState.user.username;
        }

        return Material(
          color: const Color(0xFFF0F2F5),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildWelcomeSection(userName),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, $name!",
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const Text("Find Your Device",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.search, color: Color(0xFF1A237E)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No products available in this shop"),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) => ProductCard(
              product: state.products[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    productId: state.products[index].id,
                    initialProduct: state.products[index],
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: Text("Error fetching data"));
      },
    );
  }
}