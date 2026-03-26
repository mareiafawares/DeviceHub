import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/core/network/dio_client.dart';
import 'package:front_end/features/auth/data/models/product_model.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import 'package:front_end/features/auth/presentation/pages/customer_product_details_page.dart';
import 'package:front_end/features/auth/presentation/cubit/favorite_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/favorite_state.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  static String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    return '$base${url.startsWith('/') ? url.substring(1) : url}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? _fullImageUrl(product.images.first.url)
        : null;

    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.state is AuthSuccess 
        ? (authCubit.state as AuthSuccess).user.id 
        : null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  InkWell(
                    onTap: onTap,
                    child: Hero(
                      tag: 'product_hero_${product.id}',
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              width: double.infinity,
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, state) {
                        final isFav = context.read<FavoriteCubit>().isProductFavorite(product.id);
                        
                        return GestureDetector(
                          onTap: () {
                            if (userId != null) {
                              context.read<FavoriteCubit>().toggleFavorite(product.id, userId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("يرجى تسجيل الدخول أولاً")),
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            radius: 16,
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.price.toStringAsFixed(1)} JD',
                    style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerProductDetailsPage(
                              product: product,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Order Now",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
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