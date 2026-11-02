class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String title;
  final String branchId;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.title,
    required this.branchId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'OPERATOR',
      title: json['title'] ?? 'Kỹ thuật viên',
      branchId: json['branch_id'] ?? 'sgn-01',
    );
  }
}

class OrderModel {
  final String orderId;
  final String customerName;
  final String customerPhone;
  String stage; // RECEIVED, WAITING_DEV, PROCESSING_DEV, PROCESSING_SCAN, READY_QC, COMPLETED
  final int rollCount;
  final String filmType;
  final String processType;
  final String scanner;
  final String resolution;
  final String pushPull;
  final double slaHoursLeft;
  final bool isUrgent;
  final String note;
  final String createdAt;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.stage,
    required this.rollCount,
    required this.filmType,
    required this.processType,
    required this.scanner,
    required this.resolution,
    required this.pushPull,
    required this.slaHoursLeft,
    required this.isUrgent,
    required this.note,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      stage: json['stage'] ?? 'RECEIVED',
      rollCount: json['roll_count'] ?? 1,
      filmType: json['film_type'] ?? '',
      processType: json['process_type'] ?? 'C-41',
      scanner: json['scanner'] ?? 'Noritsu HS-1800',
      resolution: json['resolution'] ?? 'JPEG',
      pushPull: json['push_pull'] ?? 'Standard',
      slaHoursLeft: (json['sla_hours_left'] ?? 48).toDouble(),
      isUrgent: json['is_urgent'] ?? false,
      note: json['note'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class QCFrameModel {
  final String frameId;
  final int frameNumber;
  final String filename;
  final String thumbUrl;
  String qcStatus; // PASSED, FLAGGED
  String? defectType;
  final String resolution;
  final String colorSpace;
  String operatorNote;

  QCFrameModel({
    required this.frameId,
    required this.frameNumber,
    required this.filename,
    required this.thumbUrl,
    required this.qcStatus,
    this.defectType,
    required this.resolution,
    required this.colorSpace,
    required this.operatorNote,
  });

  factory QCFrameModel.fromJson(Map<String, dynamic> json) {
    return QCFrameModel(
      frameId: json['frame_id'] ?? '',
      frameNumber: json['frame_number'] ?? 0,
      filename: json['filename'] ?? '',
      thumbUrl: json['thumb_url'] ?? '',
      qcStatus: json['qc_status'] ?? 'PASSED',
      defectType: json['defect_type'],
      resolution: json['resolution'] ?? '3000 x 2000 px',
      colorSpace: json['color_space'] ?? 'sRGB',
      operatorNote: json['operator_note'] ?? '',
    );
  }
}

class QCBatchModel {
  final String orderId;
  final int totalFiles;
  final int uploadedFiles;
  int passedFrames;
  int flaggedFrames;
  final String uploadStatus;
  final String speed;
  final String scanner;
  final String format;
  final String md5Checksum;
  final List<QCFrameModel> frames;

  QCBatchModel({
    required this.orderId,
    required this.totalFiles,
    required this.uploadedFiles,
    required this.passedFrames,
    required this.flaggedFrames,
    required this.uploadStatus,
    required this.speed,
    required this.scanner,
    required this.format,
    required this.md5Checksum,
    required this.frames,
  });

  factory QCBatchModel.fromJson(Map<String, dynamic> json) {
    return QCBatchModel(
      orderId: json['order_id'] ?? '',
      totalFiles: json['total_files'] ?? 0,
      uploadedFiles: json['uploaded_files'] ?? 0,
      passedFrames: json['passed_frames'] ?? 0,
      flaggedFrames: json['flagged_frames'] ?? 0,
      uploadStatus: json['upload_status'] ?? 'COMPLETED',
      speed: json['speed'] ?? '48 MB/s',
      scanner: json['scanner'] ?? 'Noritsu HS-1800',
      format: json['format'] ?? 'TIFF 16-bit',
      md5Checksum: json['md5_checksum'] ?? '',
      frames: (json['frames'] as List<dynamic>?)
              ?.map((f) => QCFrameModel.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class ServiceModel {
  final String serviceId;
  String name;
  final String filmFormat;
  final String processType;
  final String scanner;
  double basePrice;
  double pushPullFee;
  double highResFee;
  int slaHours;
  String status; // ACTIVE, PAUSED
  final String outputFormat;
  String description;

  ServiceModel({
    required this.serviceId,
    required this.name,
    required this.filmFormat,
    required this.processType,
    required this.scanner,
    required this.basePrice,
    required this.pushPullFee,
    required this.highResFee,
    required this.slaHours,
    required this.status,
    required this.outputFormat,
    required this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] ?? '',
      name: json['name'] ?? '',
      filmFormat: json['film_format'] ?? '',
      processType: json['process_type'] ?? '',
      scanner: json['scanner'] ?? '',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      pushPullFee: (json['push_pull_fee'] ?? 0).toDouble(),
      highResFee: (json['high_res_fee'] ?? 0).toDouble(),
      slaHours: json['sla_hours'] ?? 48,
      status: json['status'] ?? 'ACTIVE',
      outputFormat: json['output_format'] ?? 'JPEG',
      description: json['description'] ?? '',
    );
  }
}

class PriceHistoryModel {
  final String historyId;
  final String serviceName;
  final double oldPrice;
  final double newPrice;
  final String effectiveDate;
  final String changedBy;
  final String reason;

  PriceHistoryModel({
    required this.historyId,
    required this.serviceName,
    required this.oldPrice,
    required this.newPrice,
    required this.effectiveDate,
    required this.changedBy,
    required this.reason,
  });

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      historyId: json['history_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      oldPrice: (json['old_price'] ?? 0).toDouble(),
      newPrice: (json['new_price'] ?? 0).toDouble(),
      effectiveDate: json['effective_date'] ?? '',
      changedBy: json['changed_by'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class LabProfileModel {
  String labId;
  String brandName;
  String licenseNo;
  String region;
  String address;
  String hotline;
  String email;
  bool hasDropbox;
  String representativeName;
  String cccdNumber;
  List<String> scanners;
  String processor;
  List<String> chemistries;
  String bio;
  String operatingHours;
  String turnaroundPledge;
  String dropboxInfo;

  LabProfileModel({
    required this.labId,
    required this.brandName,
    required this.licenseNo,
    required this.region,
    required this.address,
    required this.hotline,
    required this.email,
    required this.hasDropbox,
    required this.representativeName,
    required this.cccdNumber,
    required this.scanners,
    required this.processor,
    required this.chemistries,
    required this.bio,
    required this.operatingHours,
    required this.turnaroundPledge,
    required this.dropboxInfo,
  });

  factory LabProfileModel.fromJson(Map<String, dynamic> json) {
    return LabProfileModel(
      labId: json['lab_id'] ?? '',
      brandName: json['brand_name'] ?? '',
      licenseNo: json['license_no'] ?? '',
      region: json['region'] ?? '',
      address: json['address'] ?? '',
      hotline: json['hotline'] ?? '',
      email: json['email'] ?? '',
      hasDropbox: json['has_dropbox'] ?? false,
      representativeName: json['representative_name'] ?? '',
      cccdNumber: json['cccd_number'] ?? '',
      scanners: List<String>.from(json['scanners'] ?? []),
      processor: json['processor'] ?? '',
      chemistries: List<String>.from(json['chemistries'] ?? []),
      bio: json['bio'] ?? '',
      operatingHours: json['operating_hours'] ?? '',
      turnaroundPledge: json['turnaround_pledge'] ?? '',
      dropboxInfo: json['dropbox_info'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lab_id': labId,
      'brand_name': brandName,
      'license_no': licenseNo,
      'region': region,
      'address': address,
      'hotline': hotline,
      'email': email,
      'has_dropbox': hasDropbox,
      'representative_name': representativeName,
      'cccd_number': cccdNumber,
      'scanners': scanners,
      'processor': processor,
      'chemistries': chemistries,
      'bio': bio,
      'operating_hours': operatingHours,
      'turnaround_pledge': turnaroundPledge,
      'dropbox_info': dropboxInfo,
    };
  }
}

class DisputeMessageModel {
  final String sender; // CUSTOMER, LAB, SYSTEM
  final String name;
  final String time;
  final String content;

  DisputeMessageModel({
    required this.sender,
    required this.name,
    required this.time,
    required this.content,
  });

  factory DisputeMessageModel.fromJson(Map<String, dynamic> json) {
    return DisputeMessageModel(
      sender: json['sender'] ?? 'CUSTOMER',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class DisputeModel {
  final String disputeId;
  final String orderId;
  final String customerName;
  final String customerAvatar;
  String status; // NEGOTIATING, SETTLED
  final String category;
  final String filmType;
  final double claimAmount;
  double compensationOffered;
  final String createdAt;
  final List<DisputeMessageModel> messages;

  DisputeModel({
    required this.disputeId,
    required this.orderId,
    required this.customerName,
    required this.customerAvatar,
    required this.status,
    required this.category,
    required this.filmType,
    required this.claimAmount,
    required this.compensationOffered,
    required this.createdAt,
    required this.messages,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      disputeId: json['dispute_id'] ?? '',
      orderId: json['order_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerAvatar: json['customer_avatar'] ?? '',
      status: json['status'] ?? 'NEGOTIATING',
      category: json['category'] ?? '',
      filmType: json['film_type'] ?? '',
      claimAmount: (json['claim_amount'] ?? 0).toDouble(),
      compensationOffered: (json['compensation_offered'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => DisputeMessageModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

