class OrderModel {
  final String orderId;
  final String userId;
  final String labId;
  final String labName;
  final String orderDate;
  final String status;
  final String kanbanColumn;
  final double totalAmount;
  final String shippingMethod;
  final String pickupAddress;
  final String paymentStatus;
  final String paymentMethod;
  final String? disputeId;
  final String? disputeStatus;
  final String? disputeIssue;
  final String? disputeDescription;
  final String? compensationNote;
  final List<Map<String, dynamic>> disputeMessages;
  final String? driveLink;
  final List<String> driveLinkHistory;
  final List<Map<String, dynamic>> scanPhotos;
  final List<OrderItemModel> items;
  final List<TimelineStepModel> timeline;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.labId,
    required this.labName,
    required this.orderDate,
    required this.status,
    this.kanbanColumn = 'QUEUE',
    required this.totalAmount,
    required this.shippingMethod,
    required this.pickupAddress,
    required this.paymentStatus,
    required this.paymentMethod,
    this.disputeId,
    this.disputeStatus,
    this.disputeIssue,
    this.disputeDescription,
    this.compensationNote,
    this.disputeMessages = const [],
    this.driveLink,
    this.driveLinkHistory = const [],
    this.scanPhotos = const [],
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
      kanbanColumn: json['kanban_column'] ?? 'QUEUE',
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : 0.0,
      shippingMethod: json['shipping_method'] ?? 'PICKUP',
      pickupAddress: json['pickup_address'] ?? '',
      paymentStatus: json['payment_status'] ?? 'PAID',
      paymentMethod: json['payment_method'] ?? 'MOMO',
      disputeId: json['dispute_id']?.toString(),
      disputeStatus: json['dispute_status']?.toString(),
      disputeIssue: json['dispute_issue']?.toString(),
      disputeDescription: json['dispute_description']?.toString(),
      compensationNote: json['compensation_note']?.toString(),
      disputeMessages: (json['dispute_messages'] as List<dynamic>?)
              ?.map((m) => Map<String, dynamic>.from(m as Map))
              .toList() ??
          [],
      driveLink: json['drive_link']?.toString(),
      driveLinkHistory: (json['drive_link_history'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      scanPhotos: (json['scan_photos'] as List<dynamic>?)
              ?.map((p) => Map<String, dynamic>.from(p as Map))
              .toList() ??
          [],
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

  bool get hasDispute =>
      (disputeId != null && disputeId!.isNotEmpty) ||
      (disputeStatus != null && disputeStatus!.isNotEmpty) ||
      (disputeIssue != null && disputeIssue!.isNotEmpty) ||
      (disputeDescription != null && disputeDescription!.isNotEmpty) ||
      (compensationNote != null && compensationNote!.isNotEmpty) ||
      disputeMessages.isNotEmpty;
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

