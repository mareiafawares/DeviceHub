import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/product_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final AuthRepository authRepository;
  
  List<ProductModel> _allProducts = []; 

  List<ProductModel> get allProducts => _allProducts;

  ProductCubit(this.authRepository) : super(ProductInitial());

  Future<void> fetchAllProducts() async {
    emit(ProductLoading());
    try {
      final List<ProductModel> products = await authRepository.getAllProducts();
      _allProducts = products;
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      emit(ProductError("Failed to load products: ${e.toString()}"));
    }
  }

  Future<void> fetchProducts(int shopId) async {
    emit(ProductLoading());
    try {
      final List<ProductModel> products = await authRepository.getShopProducts(shopId);
      _allProducts = products;
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      emit(ProductError("Failed to load shop products: ${e.toString()}"));
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(ProductLoaded(_allProducts));
    } else {
      final filtered = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(ProductLoaded(filtered));
    }
  }

  void filterByCategory(String category) {
    if (category == "All") {
      emit(ProductLoaded(_allProducts));
    } else {
      final filtered = _allProducts.where((p) => p.category == category).toList();
      emit(ProductLoaded(filtered));
    }
  }

  Future<void> addProduct(int shopId, Map<String, dynamic> productData) async {
    try {
      await authRepository.addProduct(shopId, productData);
      emit(ProductActionSuccess("Product added successfully!"));
      await fetchProducts(shopId);
    } catch (e) {
      emit(ProductError("Add failed: ${e.toString()}"));
    }
  }

  Future<void> deleteProduct(int productId, int shopId) async {
    try {
      await authRepository.deleteProduct(productId);
      _allProducts.removeWhere((p) => p.id == productId);
      emit(ProductActionSuccess("Product deleted successfully!"));
      emit(ProductLoaded(List.from(_allProducts)));
    } catch (e) {
      emit(ProductError("Delete failed: ${e.toString()}"));
    }
  }
}