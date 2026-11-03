class OrderModel {
  final String orderId;
  final String userId;
  final String labId;
  final String labName;
  final String orderDate;
  final String status;
  final double totalAmount;
  final String shippingMethod;
  final String pickupAddress;
  final String paymentStatus;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final List<TimelineStepModel> timeline;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.labId,
    required this.labName,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.shippingMethod,
    required this.pickupAddress,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.items,
    required this.timeline,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? '',
      labId: json['lab_id'] ?? '',
      labName: json['lab_name'] ?? 'Film Lab',
      orderDate: json['order_date'] ?? '',
      status: json['status'] ?? 'PROCESSING',
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : 0.0,
      shippingMethod: json['shipping_method'] ?? 'PICKUP',
      pickupAddress: json['pickup_address'] ?? '',
      paymentStatus: json['payment_status'] ?? 'PAID',
      paymentMethod: json['payment_method'] ?? 'MOMO',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => OrderItemModel.fromJson(i))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((t) => TimelineStepModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class OrderItemModel {
  final String itemId;
  final String name;
  final String filmName;
  final int quantity;
  final double price;
  final Map<String, dynamic>? options;

  OrderItemModel({
    required this.itemId,
    required this.name,
    required this.filmName,
    required this.quantity,
    required this.price,
    this.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      itemId: json['item_id'] ?? '',
      name: json['name'] ?? '',
      filmName: json['film_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      options: json['options'],
    );
  }
}

class TimelineStepModel {
  final int step;
  final String name;
  final String status; // COMPLETED, IN_PROGRESS, PENDING
  final String time;
  final String note;

  TimelineStepModel({
    required this.step,
    required this.name,
    required this.status,
    required this.time,
    required this.note,
  });

  factory TimelineStepModel.fromJson(Map<String, dynamic> json) {
    return TimelineStepModel(
      step: json['step'] ?? 1,
      name: json['name'] ?? '',
      status: json['status'] ?? 'PENDING',
      time: json['time'] ?? '',
      note: json['note'] ?? '',
    );
  }
}

