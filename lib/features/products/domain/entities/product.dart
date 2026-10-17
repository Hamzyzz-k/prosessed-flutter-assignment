import 'package:equatable/equatable.dart';

/// What the product grid needs. Also what the cart and wishlist store.
class ProductSummary extends Equatable {
  const ProductSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.category,
    this.brand,
  });

  final int id;
  final String title;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final String category;

  /// Some DummyJSON products (e.g. groceries) have no brand.
  final String? brand;

  /// Price after discount, rounded to cents.
  double get finalPrice => roundMoney(price * (1 - discountPercentage / 100));

  bool get hasDiscount => discountPercentage > 0;
  bool get inStock => stock > 0;

  /// "Only 3 left" threshold.
  bool get isLowStock => stock > 0 && stock <= 5;

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    discountPercentage,
    rating,
    stock,
    thumbnail,
    category,
    brand,
  ];
}

/// Everything the details screen shows.
class ProductDetails extends ProductSummary {
  const ProductDetails({
    required super.id,
    required super.title,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.thumbnail,
    required super.category,
    required this.description,
    required this.images,
    required this.reviews,
    super.brand,
    this.warranty,
    this.shipping,
    this.returnPolicy,
  });

  final String description;
  final List<String> images;
  final List<Review> reviews;
  final String? warranty;
  final String? shipping;
  final String? returnPolicy;

  /// Images to show in the carousel; falls back to the thumbnail.
  List<String> get gallery => images.isEmpty ? [thumbnail] : images;

  @override
  List<Object?> get props => [
    ...super.props,
    description,
    images,
    reviews,
    warranty,
    shipping,
    returnPolicy,
  ];
}

class Review extends Equatable {
  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  @override
  List<Object?> get props => [rating, comment, reviewerName, date];
}

/// Money is shown with two decimals; keep maths consistent with that.
double roundMoney(double value) => (value * 100).roundToDouble() / 100;
