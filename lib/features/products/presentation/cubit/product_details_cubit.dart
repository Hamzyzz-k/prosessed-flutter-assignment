import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product, {this.quantity = 1});

  final ProductDetails product;

  /// Quantity chosen with the stepper, always within 1…stock.
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.failure);

  final Failure failure;

  bool get isNotFound => failure is NotFoundFailure;

  @override
  List<Object?> get props => [failure];
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._getDetails, this.productId)
    : super(const ProductDetailsLoading());

  final GetProductDetails _getDetails;
  final int productId;

  Future<void> load() async {
    emit(const ProductDetailsLoading());
    final result = await _getDetails(productId);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => ProductDetailsLoaded(value),
      Err(:final failure) => ProductDetailsFailure(failure),
    });
  }

  void setQuantity(int quantity) {
    final current = state;
    if (current is! ProductDetailsLoaded || !current.product.inStock) return;
    final clamped = quantity.clamp(1, current.product.stock);
    emit(ProductDetailsLoaded(current.product, quantity: clamped));
  }
}
