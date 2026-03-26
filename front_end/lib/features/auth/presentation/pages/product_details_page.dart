import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:front_end/core/network/dio_client.dart';
import 'package:front_end/core/service_locator.dart';
import 'package:front_end/features/auth/data/models/product_model.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart'; 

class ProductDetailsPage extends StatefulWidget {
  final int productId;
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
  bool _isActionLoading = false;
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _setBusy(true);
      try {
        final repo = getIt<AuthRepository>();
        await repo.uploadProductImage(widget.productId, File(image.path));
        await _fetchProduct();

        if (!mounted) return;
        _showSnackBar("Image uploaded successfully", Colors.green);
      } catch (e) {
        if (!mounted) return;
        _showSnackBar("Upload failed: $e", Colors.red);
      } finally {
        _setBusy(false);
      }
    }
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

  void _setBusy(bool value) => setState(() => _isActionLoading = value);

  Future<void> _deleteImage(int imageId) async {
    _setBusy(true);
    try {
      final repo = getIt<AuthRepository>();
      await repo.deleteProductImage(widget.productId, imageId);
      await _fetchProduct();
      
      _showSnackBar("Image deleted", Colors.orange);
    } catch (e) {
      _showSnackBar("Delete failed: $e", Colors.red);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    _setBusy(true);
    try {
      final repo = getIt<AuthRepository>();
      await repo.deleteReview(widget.productId, reviewId); 
      await _fetchProduct();
      _showSnackBar("Review deleted", Colors.orange);
    } catch (e) {
      _showSnackBar("Failed to delete review: $e", Colors.red);
    } finally {
      _setBusy(false);
    }
  }

  static String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    return '$base${url.startsWith('/') ? url.substring(1) : url}';
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showDeleteConfirmation(int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(reviewId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
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
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
      );
    }

    return Stack(
      children: [
        _buildContent(context, _product!),
        if (_isActionLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
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
                          return Image.network(
                            imageUrls[index],
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
                            '${product.discountPrice!.toStringAsFixed(1)} JD',
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
                            Icon(Icons.category_outlined, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              product.category,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Sold ${product.salesCount}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const Text(
                    "Product Gallery",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length + 1, 
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFF1A237E), width: 1.5),
                              ),
                              child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF1A237E)),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrls[index - 1]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 18,
                              child: GestureDetector(
                                onTap: () => _deleteImage(product.images[index - 1].id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (product.reviews.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "No reviews yet.",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                                    child: const Icon(Icons.person_rounded, color: Color(0xFF1A237E), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  Icons.star_rounded,
                                                  size: 16,
                                                  color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                              onPressed: () => _showDeleteConfirmation(review.id),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          review.comment ?? "No comment",
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
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