import 'dart:typed_data';

class Product {
  final int id;
  final String name;
  final String price;
  final String location;
  final String timeAgo;
  final String? imageUrl; // 기존 에셋 이미지용
  final Uint8List? imageBytes; // 새로 등록된 상품 이미지용
  final int chatCount;
  final int likeCount;
  final ProductStatus status;
  final String? category;
  final String? description;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.location,
    required this.timeAgo,
    this.imageUrl,
    this.imageBytes,
    this.chatCount = 0,
    this.likeCount = 0,
    this.status = ProductStatus.selling,
    this.category,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum ProductStatus {
  selling('판매중'),
  reserved('예약중'),
  sold('판매완료');

  final String displayName;
  const ProductStatus(this.displayName);
}
