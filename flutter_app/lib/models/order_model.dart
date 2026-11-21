class OrderModel {
  final String orderId;
  final String userId;
  final String labId;
  final String labName;
  final String orderDate;
  final String status;
  final String kanbanColumn;
  final double totalAmount;
  final double shippingFee;
  final String shippingMethod;
  final String pickupAddress;
  final String pickupPhone;
  final String paymentStatus;
  final String paymentMethod;
  final String? cancelReason;
  final Map<String, dynamic>? shipment;
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
    this.shippingFee = 0,
    required this.shippingMethod,
    required this.pickupAddress,
    this.pickupPhone = '',
    required this.paymentStatus,
    required this.paymentMethod,
    this.cancelReason,
    this.shipment,
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
      shippingFee: (json['shipping_fee'] is num)
          ? (json['shipping_fee'] as num).toDouble()
          : 0.0,
      shippingMethod: json['shipping_method'] ?? 'PICKUP',
      pickupAddress: json['pickup_address'] ?? '',
      pickupPhone: json['pickup_phone'] ?? '',
      paymentStatus: json['payment_status'] ?? 'PAID',
      paymentMethod: json['payment_method'] ?? 'VNPAY',
      cancelReason: json['cancel_reason']?.toString(),
      shipment: json['shipment'] is Map
          ? Map<String, dynamic>.from(json['shipment'] as Map)
          : null,
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

  bool get isPickupOrder =>
      shippingMethod.toUpperCase() == 'AHAMOVE_PICKUP' || shipment != null;

  String get normalizedShipmentState {
    if (shipment == null) return 'UNBOOKED';
    final aha = (shipment?['ahamove_status'] ?? '').toString().trim().toUpperCase();
    final db = (shipment?['status'] ?? '').toString().trim().toUpperCase();
    if (db == 'CANCELLED' || aha == 'CANCELLED') return 'CANCELLED';
    if (db == 'DELIVERED' || aha == 'COMPLETED') return 'DELIVERED';
    if (db == 'PICKED_UP') return 'PICKED_UP';
    if (db == 'IN_TRANSIT' || aha == 'IN PROCESS') return 'IN_TRANSIT';
    if (db == 'ASSIGNED' || aha == 'ACCEPTED') return 'ASSIGNED';
    if (db == 'FAILED' || aha == 'FAILED') return 'FAILED';
    return 'FINDING_DRIVER';
  }

  String get shipmentBadgeVi {
    switch (normalizedShipmentState) {
      case 'FINDING_DRIVER':
        return 'ĐANG TÌM TÀI XẾ';
      case 'ASSIGNED':
        return 'TÀI XẾ ĐÃ NHẬN';
      case 'PICKED_UP':
        return 'ĐÃ LẤY FILM';
      case 'IN_TRANSIT':
        return 'ĐANG GIAO TỚI LAB';
      case 'DELIVERED':
        return 'ĐÃ TỚI LAB';
      case 'CANCELLED':
        return 'ĐÃ HỦY CHUYẾN';
      case 'FAILED':
        return 'GIAO THẤT BẠI';
      default:
        return paymentStatus.toUpperCase() == 'PENDING' ? 'CHỜ THANH TOÁN' : 'CHỜ GỌI SHIPPER';
    }
  }

  String get shipmentHeadlineVi {
    switch (normalizedShipmentState) {
      case 'FINDING_DRIVER':
        return 'Đang tìm tài xế';
      case 'ASSIGNED':
        return 'Tài xế đã nhận đơn';
      case 'PICKED_UP':
        return 'Tài xế đã nhận cuộn film';
      case 'IN_TRANSIT':
        return 'Tài xế đang giao tới $labName';
      case 'DELIVERED':
        return 'Đã giao tới $labName thành công';
      case 'CANCELLED':
        return 'Chuyến xe đã bị hủy';
      case 'FAILED':
        return 'Giao nhận chưa thành công';
      default:
        return paymentStatus.toUpperCase() == 'PENDING'
            ? 'Chờ thanh toán trước khi gọi tài xế'
            : 'Đang chờ điều phối tài xế lấy film';
    }
  }

  String get shipmentHintVi {
    switch (normalizedShipmentState) {
      case 'FINDING_DRIVER':
        return 'Hệ thống đang kết nối với tài xế AhaMove gần bạn, vui lòng để ý điện thoại nhé.';
      case 'ASSIGNED':
        return 'Tài xế đang trên đường đến điểm hẹn — hãy chuẩn bị sẵn cuộn film của bạn nhé!';
      case 'PICKED_UP':
        return 'Tài xế đã nhận cuộn film của bạn và chuẩn bị xuất phát tới $labName.';
      case 'IN_TRANSIT':
        return 'Cuộn film của bạn đang được shipper vận chuyển tới quầy tiếp nhận $labName.';
      case 'DELIVERED':
        return '$labName đã nhận được cuộn film của bạn và sẵn sàng đưa vào tráng scan.';
      case 'CANCELLED':
        return 'Vận đơn đã hủy. Bạn hoặc tiệm Lab có thể bấm đặt lại chuyến mới bất kỳ lúc nào.';
      case 'FAILED':
        return 'Shipper chưa thể hoàn tất chuyến, vui lòng kiểm tra lại SĐT và địa chỉ nhận hàng.';
      default:
        return paymentStatus.toUpperCase() == 'PENDING'
            ? 'Vui lòng hoàn tất thanh toán để hệ thống gọi tài xế AhaMove tới lấy cuộn film.'
            : 'Bạn hoặc tiệm Lab có thể bấm gọi tài xế AhaMove tới lấy film ngay bây giờ.';
    }
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

