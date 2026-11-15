class UserModel {
  final String userId;
  final String email;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final String? bio;
  final String? address;
  final String? labId;

  UserModel({
    required this.userId,
    required this.email,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.bio,
    this.address,
    this.labId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? 'Khách hàng',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'Customer',
      bio: json['bio'],
      address: json['address'],
      labId: json['lab_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'bio': bio,
      'address': address,
      'lab_id': labId,
    };
  }
}

