import 'package:flutter/material.dart';
import 'package:front_end/core/network/dio_client.dart';
import 'package:front_end/core/service_locator.dart';
import 'package:front_end/features/auth/data/models/product_model.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  /// Optional: show this immediately while fetching fresh data from GET /products/{id}.
  final ProductModel? initialProduct;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductModel? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    if (widget.initialProduct != null) {
      _loading = false;
    }
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    if (!_loading && _product != null && _product!.id == widget.productId) {
      _loading = true;
      setState(() {});
    }
    try {
      final repo = getIt<AuthRepository>();
      final product = await repo.getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      });
    }
  }

  static String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    return '$base${url.startsWith('/') ? url.substring(1) : url}';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _fetchProduct,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry"),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A237E)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
      );
    }

    return _buildContent(context, _product!);
  }

  Widget _buildContent(BuildContext context, ProductModel product) {
    final imageUrls = product.images
        .map((i) => _fullImageUrl(i.url))
        .where((u) => u.isNotEmpty)
        .toList();
    final hasImages = imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'product_hero_${product.id}',
                child: hasImages
                    ? PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          );
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                            ),
                            Text(
                              '${product.price.toStringAsFixed(1)} JD',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        if (product.discountPrice != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${product.discountPrice!.toStringAsFixed(1)} JD (sale)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.category_outlined,
                                size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.shopping_bag_outlined,
                                size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Sold ${product.salesCount}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.stockQuantity > 0
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.stockQuantity > 0
                                    ? 'In stock: ${product.stockQuantity}'
                                    : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: product.stockQuantity > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Reviews",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            Text(
                              "${product.reviews.length} review(s)",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (product.reviews.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "No reviews yet.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: product.reviews.length,
                            separatorBuilder: (_, __) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final review = product.reviews[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF1A237E),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: i < review.rating
                                                  ? Colors.amber
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          review.comment ?? "No comment",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: product.stockQuantity > 0
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Added to cart"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              product.stockQuantity > 0 ? "Add to cart" : "Out of stock",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF1A237E),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
