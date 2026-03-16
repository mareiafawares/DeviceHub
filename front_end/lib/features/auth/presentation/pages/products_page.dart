import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../data/models/product_model.dart';
import '../widgets/add_product_sheet.dart';

class ProductsPage extends StatefulWidget {
  final int shopId;
  final String shopName;
  final String shopDescription;
  final String? shopImageUrl;

  const ProductsPage({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.shopDescription,
    this.shopImageUrl,
  });

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
      backgroundColor: const Color(0xFFF8FAFF),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _openAddProductSheet(context),
              backgroundColor: const Color(0xFF2D43A6),
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("Add Product",
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildShopHeader(),
            _buildSearchHeader(),
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                return _buildBodyContent(state);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildShopHeader() {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2D43A6),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.shopName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeaderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  backgroundImage: _getShopImageProvider(),
                  child: widget.shopImageUrl == null || widget.shopImageUrl!.isEmpty
                      ? const Icon(Icons.storefront_rounded, size: 35, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.shopDescription,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getShopImageProvider() {
    if (widget.shopImageUrl == null || widget.shopImageUrl!.isEmpty) return null;
    if (widget.shopImageUrl!.startsWith('http')) {
      return NetworkImage(widget.shopImageUrl!);
    } else {
      return FileImage(File(widget.shopImageUrl!));
    }
  }

  Widget _buildHeaderImage() {
    if (widget.shopImageUrl != null && widget.shopImageUrl!.isNotEmpty) {
      return widget.shopImageUrl!.startsWith('http')
          ? Image.network(widget.shopImageUrl!, fit: BoxFit.cover)
          : Image.file(File(widget.shopImageUrl!), fit: BoxFit.cover);
    }
    return Container(color: const Color(0xFF2D43A6));
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

    final products = context.read<ProductCubit>().allProducts;

    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("Your shop is empty!", 
                  style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Start adding products to see them here", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildProductCard(ProductModel product) {
    String? imageUrl = product.images.isNotEmpty ? product.images.first.url : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildProductImage(imageUrl),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _confirmDelete(product),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${product.price} JD",
                        style: const TextStyle(
                            color: Color(0xFF2D43A6), fontWeight: FontWeight.w900, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.stockQuantity > 0 ? "Stock: ${product.stockQuantity}" : "Out",
                        style: TextStyle(
                            color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.shopping_bag_outlined, color: Colors.grey[300], size: 40),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2D43A6),
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_rounded), label: "Store"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete '${product.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<ProductCubit>().deleteProduct(product.id, widget.shopId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          onChanged: (value) => context.read<ProductCubit>().searchProducts(value),
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2D43A6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  @override double get maxExtent => 70.0;
  @override double get minExtent => 70.0;
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}