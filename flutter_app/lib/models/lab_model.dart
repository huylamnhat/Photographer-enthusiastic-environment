class LabModel {
  final String labId;
  final String name;
  final String tagline;
  final String address;
  final String city;
  final String phone;
  final String email;
  final double rating;
  final int reviewCount;
  final int turnaroundHours;
  final List<String> scannerModels;
  final List<String> supportedFormats;
  final List<String> supportedProcesses;
  final String coverImage;
  final String logoUrl;
  final bool isVerified;
  final String priceRange;
  final String description;
  final List<ServicePackageModel> packages;

  LabModel({
    required this.labId,
    required this.name,
    required this.tagline,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.rating,
    required this.reviewCount,
    required this.turnaroundHours,
    required this.scannerModels,
    required this.supportedFormats,
    required this.supportedProcesses,
    required this.coverImage,
    required this.logoUrl,
    required this.isVerified,
    required this.priceRange,
    required this.description,
    this.packages = const [],
  });

  factory LabModel.fromJson(Map<String, dynamic> json) {
    return LabModel(
      labId: json['lab_id'] ?? '',
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      reviewCount: json['review_count'] ?? 0,
      turnaroundHours: json['turnaround_hours'] ?? 12,
      scannerModels: List<String>.from(json['scanner_models'] ?? []),
      supportedFormats: List<String>.from(json['supported_formats'] ?? []),
      supportedProcesses: List<String>.from(json['supported_processes'] ?? []),
      coverImage: json['cover_image'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
      priceRange: json['price_range'] ?? '',
      description: json['description'] ?? '',
      packages: (json['packages'] as List<dynamic>?)
              ?.map((p) => ServicePackageModel.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ServicePackageModel {
  final String packageId;
  final String labId;
  final String name;
  final String filmFormat;
  final String processType;
  final String scanResolution;
  final double price;
  final int estimatedHours;
  final String description;

  ServicePackageModel({
    required this.packageId,
    required this.labId,
    required this.name,
    required this.filmFormat,
    required this.processType,
    required this.scanResolution,
    required this.price,
    required this.estimatedHours,
    required this.description,
  });

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    return ServicePackageModel(
      packageId: json['package_id'] ?? '',
      labId: json['lab_id'] ?? '',
      name: json['name'] ?? '',
      filmFormat: json['film_format'] ?? '135',
      processType: json['process_type'] ?? 'C-41',
      scanResolution: json['scan_resolution'] ?? 'M',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 50000.0,
      estimatedHours: json['estimated_hours'] ?? 12,
      description: json['description'] ?? '',
    );
  }
}

