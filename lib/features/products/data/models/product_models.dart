import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

/// DummyJSON sends whole numbers for some prices (e.g. `10`), so every
/// number is read as `num` first.
double _double(Object? value) => (value as num?)?.toDouble() ?? 0;

class ProductSummaryModel {
  const ProductSummaryModel({
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

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: _double(json['price']),
      discountPercentage: _double(json['discountPercentage']),
      rating: _double(json['rating']),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?,
    );
  }

  factory ProductSummaryModel.fromEntity(ProductSummary p) {
    return ProductSummaryModel(
      id: p.id,
      title: p.title,
      price: p.price,
      discountPercentage: p.discountPercentage,
      rating: p.rating,
      stock: p.stock,
      thumbnail: p.thumbnail,
      category: p.category,
      brand: p.brand,
    );
  }

  /// Fields requested with `?select=` to keep list payloads small.
  static const selectFields =
      'id,title,price,discountPercentage,rating,stock,thumbnail,category,brand';

  final int id;
  final String title;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final String category;
  final String? brand;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'thumbnail': thumbnail,
    'category': category,
    if (brand != null) 'brand': brand,
  };

  ProductSummary toEntity() => ProductSummary(
    id: id,
    title: title,
    price: price,
    discountPercentage: discountPercentage,
    rating: rating,
    stock: stock,
    thumbnail: thumbnail,
    category: category,
    brand: brand,
  );
}

class ProductPageModel {
  const ProductPageModel({
    required this.products,
    required this.total,
    required this.skip,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    return ProductPageModel(
      products: (json['products'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ProductSummaryModel.fromJson)
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
    );
  }

  final List<ProductSummaryModel> products;
  final int total;
  final int skip;

  Map<String, dynamic> toJson() => {
    'products': products.map((p) => p.toJson()).toList(),
    'total': total,
    'skip': skip,
  };

  ProductPage toEntity({bool isFromCache = false}) => ProductPage(
    items: products.map((p) => p.toEntity()).toList(),
    total: total,
    skip: skip,
    isFromCache: isFromCache,
  );
}

class ReviewModel {
  const ReviewModel({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String? ?? '',
    reviewerName: json['reviewerName'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? ''),
  );

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  Review toEntity() => Review(
    rating: rating,
    comment: comment,
    reviewerName: reviewerName,
    date: date,
  );
}

class ProductDetailsModel {
  const ProductDetailsModel({
    required this.summary,
    required this.description,
    required this.images,
    required this.reviews,
    this.warranty,
    this.shipping,
    this.returnPolicy,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      summary: ProductSummaryModel.fromJson(json),
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? const []).cast<String>(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList(),
      warranty: json['warrantyInformation'] as String?,
      shipping: json['shippingInformation'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
    );
  }

  final ProductSummaryModel summary;
  final String description;
  final List<String> images;
  final List<ReviewModel> reviews;
  final String? warranty;
  final String? shipping;
  final String? returnPolicy;

  ProductDetails toEntity() => ProductDetails(
    id: summary.id,
    title: summary.title,
    price: summary.price,
    discountPercentage: summary.discountPercentage,
    rating: summary.rating,
    stock: summary.stock,
    thumbnail: summary.thumbnail,
    category: summary.category,
    brand: summary.brand,
    description: description,
    images: images,
    reviews: reviews.map((r) => r.toEntity()).toList(),
    warranty: warranty,
    shipping: shipping,
    returnPolicy: returnPolicy,
  );
}

class CategoryModel {
  const CategoryModel({required this.slug, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel(slug: json['slug'] as String, name: json['name'] as String);

  final String slug;
  final String name;

  Category toEntity() => Category(slug: slug, name: name);
}
