import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/core/network/dio_client.dart' show kBaseUrl, createDio;
import 'package:front_end/core/auth/token_storage.dart'; 
import 'package:front_end/features/auth/data/models/product_model.dart';
import 'package:front_end/features/auth/presentation/cubit/cart_cubit.dart';

class CustomerProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const CustomerProductDetailsPage({super.key, required this.product});

  @override
  State<CustomerProductDetailsPage> createState() => _CustomerProductDetailsPageState();
}

class _CustomerProductDetailsPageState extends State<CustomerProductDetailsPage> {
  int _quantity = 1;
  final TextEditingController _reviewController = TextEditingController();
  int _userRating = 5;
  bool _isSubmitting = false;
  int _currentImageIndex = 0; 

  late Dio _dio;

  @override
  void initState() {
    super.initState();
    final storage = SecureTokenStorage();
    _dio = createDio(storage);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }


  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/350';
    if (url.startsWith('http')) return url;
    final base = kBaseUrl.endsWith('/') ? kBaseUrl : '$kBaseUrl/';
    return '$base${url.startsWith('/') ? url.substring(1) : url}';
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      _showSnackBar("Please write a comment first", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _dio.post(
        'products/reviews/', 
        data: {
          "product_id": widget.product.id,
          "rating": _userRating,
          "comment": comment,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Review submitted successfully!", isError: false);
        _reviewController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _userRating = 5;
          _isSubmitting = false;
        });
      }
    } on DioException catch (e) {
      setState(() => _isSubmitting = false);
      String errorMsg = e.response?.statusCode == 401 
          ? "Unauthorized: Login again" 
          : "Failed to submit review";
      _showSnackBar(errorMsg, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.product.images.map((i) => _fullImageUrl(i.url)).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        bottomNavigationBar: _buildBottomBar(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    if (imageUrls.isNotEmpty)
                      PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) => Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => 
                            const Center(child: Icon(Icons.broken_image, size: 50)),
                        ),
                      )
                    else
                      const Center(child: Icon(Icons.image_not_supported, size: 80)),
                    
                    if (imageUrls.length > 1)
                      Positioned(
                        bottom: 20, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imageUrls.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentImageIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(widget.product.name, 
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        Text("${widget.product.price} JD", 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(widget.product.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                    const SizedBox(height: 25),

                    const Text("Select Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _quantityBtn(Icons.remove, () {
                          if (_quantity > 1) setState(() => _quantity--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text("$_quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        _quantityBtn(Icons.add, () {
                          if (_quantity < widget.product.stockQuantity) setState(() => _quantity++);
                        }),
                        const SizedBox(width: 15),
                        Text("(Stock: ${widget.product.stockQuantity})", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),

                    const Divider(height: 40),
                    const Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    if (widget.product.reviews.isEmpty)
                      const Text("No reviews yet.", style: TextStyle(color: Colors.grey))
                    else
                      ...widget.product.reviews.map((r) => _buildReviewItem(r)).toList(),

                    const SizedBox(height: 30),
                    _buildAddReviewSection(),
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

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
        foregroundColor: const Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
        child: const Icon(Icons.person, color: Color(0xFF1A237E), size: 20),
      ),
      title: Row(
        children: List.generate(5, (i) => Icon(
          Icons.star_rounded, size: 14,
          color: i < (review.rating ?? 0) ? Colors.amber : Colors.grey[300],
        )),
      ),
      subtitle: Text(review.comment ?? ""),
    );
  }

  Widget _buildAddReviewSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                onPressed: () => setState(() => _userRating = index + 1),
                icon: Icon(index < _userRating ? Icons.star_rounded : Icons.star_outline_rounded),
                color: Colors.amber, iconSize: 32,
              )),
            ),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(hintText: "Your feedback...", border: InputBorder.none),
              maxLines: 2,
            ),
            _isSubmitting 
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _submitReview, 
                  icon: const Icon(Icons.send), 
                  label: const Text("Submit"),
                )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          context.read<CartCubit>().addToCart(widget.product, widget.product.shopName, quantity: _quantity);
          _showSnackBar("Added $_quantity to cart");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}