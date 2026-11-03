class ArchivePhotoModel {
  final String photoId;
  final String userId;
  final String orderId;
  final String rollCode;
  final String title;
  final String imageUrl;
  final String thumbnailUrl;
  final String albumName;
  bool isFavorite;
  final String createdAt;
  final PhotoMetadataModel metadata;

  ArchivePhotoModel({
    required this.photoId,
    required this.userId,
    required this.orderId,
    required this.rollCode,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.albumName,
    required this.isFavorite,
    required this.createdAt,
    required this.metadata,
  });

  factory ArchivePhotoModel.fromJson(Map<String, dynamic> json) {
    return ArchivePhotoModel(
      photoId: json['photo_id'] ?? '',
      userId: json['user_id'] ?? '',
      orderId: json['order_id'] ?? '',
      rollCode: json['roll_code'] ?? '',
      title: json['title'] ?? 'Ảnh scan',
      imageUrl: json['image_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      albumName: json['album_name'] ?? 'Chung',
      isFavorite: json['is_favorite'] ?? false,
      createdAt: json['created_at'] ?? '',
      metadata: PhotoMetadataModel.fromJson(json['metadata'] ?? {}),
    );
  }
}

class PhotoMetadataModel {
  final String camera;
  final String lens;
  final String filmStock;
  final int iso;
  final String aperture;
  final String shutterSpeed;
  final String focalLength;
  final String process;
  final String lab;
  final String dimensions;
  final String fileSize;

  PhotoMetadataModel({
    required this.camera,
    required this.lens,
    required this.filmStock,
    required this.iso,
    required this.aperture,
    required this.shutterSpeed,
    required this.focalLength,
    required this.process,
    required this.lab,
    required this.dimensions,
    required this.fileSize,
  });

  factory PhotoMetadataModel.fromJson(Map<String, dynamic> json) {
    return PhotoMetadataModel(
      camera: json['camera'] ?? 'N/A',
      lens: json['lens'] ?? 'N/A',
      filmStock: json['film_stock'] ?? 'N/A',
      iso: json['iso'] ?? 400,
      aperture: json['aperture'] ?? 'N/A',
      shutterSpeed: json['shutter_speed'] ?? 'N/A',
      focalLength: json['focal_length'] ?? 'N/A',
      process: json['process'] ?? 'C-41',
      lab: json['lab'] ?? 'Film Lab',
      dimensions: json['dimensions'] ?? '',
      fileSize: json['file_size'] ?? '',
    );
  }
}

