import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/data/models/product_model.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    _fetchInitialFavorites();
  }

  void _fetchInitialFavorites() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<FavoriteCubit>().loadFavorites(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            );
          } else if (state is FavoriteError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Your favorites list is currently empty",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final favItem = state.favorites[index];
                
                final product = ProductModel(
                  id: favItem.id,
                  name: favItem.name,
                  description: favItem.description,
                  price: favItem.price,
                  category: favItem.category,
                  status: favItem.status,
                  images: [ProductImageModel(url: favItem.imageUrl, id: 1)],
                  ownerId: 0, 
                  shopId: favItem.shopId,
                  stockQuantity: 1, 
                  shopName: '', 
                  reviews: [], 
                  salesCount: 1,
                );

                return ProductCard(
                  product: product,
                  onTap: () {
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}