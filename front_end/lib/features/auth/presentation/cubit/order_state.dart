import '../../data/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}


class SingleOrderLoaded extends OrderState {
  final OrderModel order;
  SingleOrderLoaded(this.order);
}

class OrderSuccess extends OrderState {
  final String message;
 
  final int? orderId; 
  OrderSuccess(this.message, {this.orderId});
}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}

class OrderStatusUpdated extends OrderState {
  final String message;
  OrderStatusUpdated(this.message);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}