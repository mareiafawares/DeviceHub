import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../data/models/product_model.dart';
import '../widgets/add_product_sheet.dart';
import 'dart:io';

class ProductsPage extends StatefulWidget {
  final int shopId;
  const ProductsPage({super.key, required this.shopId});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductCubit>().fetchProducts(widget.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _openAddProductSheet(context),
              backgroundColor: const Color(0xFF2D43A6),
              elevation: 4,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text("New Product",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<ProductCubit>().fetchProducts(widget.shopId);
          }
        },
        child: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(),
                _buildSearchHeader(),
                _buildBodyContent(state),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2D43A6),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        title: const Text(
          "Inventory Stock",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D43A6), Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchHeaderDelegate(),
    );
  }

  Widget _buildBodyContent(ProductState state) {
    if (state is ProductLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF2D43A6))),
      );
    }

    if (state is ProductError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(state.message, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => context.read<ProductCubit>().fetchProducts(widget.shopId),
                  child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (state is ProductLoaded || state is ProductActionSuccess) {
      final products = (state is ProductLoaded) ? state.products : context.read<ProductCubit>().allProducts;

      if (products.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("No products found in this shop", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildProductCard(products[index]),
            childCount: products.length,
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildProductImage(product.imageUrl),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _confirmDelete(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text("\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Color(0xFF2D43A6), fontWeight: FontWeight.w800, fontSize: 15)),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: product.stockQuantity > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 5),
                      Text("Qty: ${product.stockQuantity}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image)),
      );
    } else if (url.isNotEmpty && File(url).existsSync()) {
      return Image.file(
        File(url),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image)),
      );
    }
    return Container(color: Colors.grey[100], child: const Icon(Icons.image));
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 0) Navigator.pop(context);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2D43A6),
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Products"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
      ],
    );
  }

  void _openAddProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductSheet(shopId: widget.shopId),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Remove Product"),
        content: Text("Are you sure you want to delete ${product.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                context.read<ProductCubit>().deleteProduct(product.id, widget.shopId);
                Navigator.pop(ctx);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF1F4F9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      child: TextField(
        onChanged: (value) => context.read<ProductCubit>().searchProducts(value),
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2D43A6)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80.0;
  @override
  double get minExtent => 80.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}