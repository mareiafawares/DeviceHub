import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_state.dart';
import '../../domain/repositories/auth_repository.dart';

class OrderCubit extends Cubit<OrderState> {
  final AuthRepository authRepository;

  OrderCubit(this.authRepository) : super(OrderInitial());

  
  Future<void> fetchShopOrders(int shopId) async {
    emit(OrderLoading());
    final result = await authRepository.getShopOrders(shopId);
    
    result.fold(
      
      (failureString) => emit(OrderError(failureString)), 
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

 
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final result = await authRepository.updateOrderStatus(
      orderId: orderId, 
      status: newStatus,
    );

    result.fold(
     
      (failureString) => emit(OrderError(failureString)), 
      (successMessage) => emit(OrderStatusUpdated(successMessage)),
    );
  }
}