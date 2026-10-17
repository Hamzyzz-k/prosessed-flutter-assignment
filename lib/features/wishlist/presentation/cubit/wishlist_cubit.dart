import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/domain/repositories/wishlist_repository.dart';

/// The list of favourited products, newest first.
class WishlistCubit extends Cubit<List<ProductSummary>> {
  WishlistCubit(this._repository) : super(const []);

  final WishlistRepository _repository;

  Future<void> load() async {
    final result = await _repository.load();
    if (!isClosed) emit(result.valueOrNull ?? const []);
  }

  bool contains(int productId) => state.any((p) => p.id == productId);

  Future<void> toggle(ProductSummary product) async {
    final items = toggleWishlist(state, product);
    emit(items);
    await _repository.save(items);
  }
}
