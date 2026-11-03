class ListingModel {
  final String listingId;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final String title;
  final String category;
  final String condition;
  final double price;
  final String status;
  final String location;
  final String phoneContact;
  final String zaloContact;
  final List<String> imageUrls;
  final String description;
  final String createdAt;

  ListingModel({
    required this.listingId,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.status,
    required this.location,
    required this.phoneContact,
    required this.zaloContact,
    required this.imageUrls,
    required this.description,
    required this.createdAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      listingId: json['listing_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? 'Người bán',
      sellerAvatar: json['seller_avatar'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Máy ảnh Film',
      condition: json['condition'] ?? 'Đã qua sử dụng',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'ACTIVE',
      location: json['location'] ?? 'Toàn quốc',
      phoneContact: json['phone_contact'] ?? '',
      zaloContact: json['zalo_contact'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

