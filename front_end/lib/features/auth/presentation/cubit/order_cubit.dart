import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_state.dart';
import '../../data/models/order_model.dart'; 
import '../../domain/repositories/auth_repository.dart';

class OrderCubit extends Cubit<OrderState> {
  final AuthRepository authRepository;

  OrderCubit(this.authRepository) : super(OrderInitial());

  // 1. إرسال طلب جديد (للمشتري)
  Future<void> placeOrder(OrderModel orderRequest) async {
    emit(OrderLoading());
    final result = await authRepository.createOrder(orderRequest);

    result.fold(
      (failure) => emit(OrderError(failure)),
      (message) => emit(OrderSuccess(message)), 
    );
  }

  // 2. جلب طلبات المشتري (لصفحة MyOrdersPage)
  Future<void> fetchMyOrders() async {
    emit(OrderLoading());
    final result = await authRepository.getMyOrders(); 
    
    result.fold(
      (failure) => emit(OrderError(failure)), 
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  // 3. جلب تفاصيل طلب معين (للتتبع)
  Future<void> fetchOrderDetails(int orderId) async {
    final result = await authRepository.getMyOrders(); 
    
    result.fold(
      (failure) => emit(OrderError(failure)), 
      (orders) {
        try {
          final order = orders.firstWhere((o) => o.id == orderId);
          emit(SingleOrderLoaded(order)); 
        } catch (e) {
          emit(OrderError("Order not found"));
        }
      },
    );
  }

  // 4. جلب طلبات المحل (للبائع - SellerOrdersPage)
  Future<void> fetchShopOrders(int shopId) async {
    emit(OrderLoading());
    final result = await authRepository.getShopOrders(shopId);
    
    result.fold(
      (failure) => emit(OrderError(failure)), 
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  // 5. تحديث حالة الطلب (للبائع)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final result = await authRepository.updateOrderStatus(
      orderId: orderId, 
      status: newStatus,
    );

    result.fold(
      (failure) => emit(OrderError(failure)), 
      (message) {
        emit(OrderStatusUpdated(message));
        // لا نحتاج لاستدعاء fetchOrderDetails هنا لأن الـ UI في صفحة التاجر 
        // يقوم بإعادة جلب القائمة كاملة عند سماع حالة OrderStatusUpdated
      },
    );
  }
}