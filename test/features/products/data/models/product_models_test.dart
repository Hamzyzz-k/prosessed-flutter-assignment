import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ProductPageModel', () {
    test('parses a real /products page', () {
      final page = ProductPageModel.fromJson(fixture('products_page.json'))
          .toEntity();

      expect(page.items, hasLength(2));
      expect(page.total, 194);
      expect(page.skip, 0);
      expect(page.hasMore, isTrue);
      expect(page.items.first.title, 'Essence Mascara Lash Princess');
      expect(page.items.first.brand, 'Essence');
    });

    test('handles a product without a brand', () {
      final page = ProductPageModel.fromJson(fixture('products_page.json'))
          .toEntity();

      expect(page.items[1].brand, isNull);
    });

    test('round-trips through toJson for the offline cache', () {
      final model = ProductPageModel.fromJson(fixture('products_page.json'));
      final again = ProductPageModel.fromJson(model.toJson());

      expect(again.toEntity(), model.toEntity());
    });
  });

  group('ProductDetailsModel', () {
    test('parses images, reviews and policies from /products/1', () {
      final product = ProductDetailsModel.fromJson(fixture('product.json'))
          .toEntity();

      expect(product.id, 1);
      expect(product.gallery, isNotEmpty);
      expect(product.reviews, hasLength(3));
      expect(product.reviews.first.rating, 3);
      expect(product.reviews.first.date, isNotNull);
      expect(product.shipping, 'Ships in 3-5 business days');
      expect(product.finalPrice, closeTo(8.94, 0.001));
    });
  });

  test('CategoryModel parses /products/categories', () {
    final categories = fixtureList('categories.json')
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();

    expect(categories.first.slug, 'beauty');
    expect(categories.first.name, 'Beauty');
  });
}
