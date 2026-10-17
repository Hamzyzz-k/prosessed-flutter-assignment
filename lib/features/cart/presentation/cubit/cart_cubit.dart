import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

enum CheckoutStatus { idle, placing, success, failure }

class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.summary = CartSummary.empty,
    this.isLoaded = false,
    this.checkout = CheckoutStatus.idle,
    this.order,
    this.failure,
  });

  final List<CartItem> items;
  final CartSummary summary;

  /// False until the saved cart has been read from storage.
  final bool isLoaded;
  final CheckoutStatus checkout;

  /// Set after a successful order, for the confirmation screen.
  final OrderConfirmation? order;
  final Failure? failure;

  bool get isEmpty => items.isEmpty;

  int quantityOf(int productId) => items
      .where((i) => i.product.id == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [
    items,
    summary,
    isLoaded,
    checkout,
    order,
    failure,
  ];
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this._loadCart, this._saveCart, this._summarise, this._placeOrder)
    : super(const CartState());

  final LoadCart _loadCart;
  final SaveCart _saveCart;
  final CalculateCartSummary _summarise;
  final PlaceOrder _placeOrder;

  CartItem? _lastRemoved;
  int _lastRemovedIndex = 0;

  Future<void> load() async {
    final result = await _loadCart();
    if (isClosed) return;
    _emitItems(result.valueOrNull ?? const []);
  }

  Future<void> add(ProductSummary product, {int quantity = 1}) =>
      _update(CartRules.add(state.items, product, quantity));

  Future<void> setQuantity(int productId, int quantity) =>
      _update(CartRules.setQuantity(state.items, productId, quantity));

  Future<void> remove(int productId) async {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    _lastRemoved = state.items[index];
    _lastRemovedIndex = index;
    await _update(CartRules.remove(state.items, productId));
  }

  /// Puts the last removed line back where it was.
  Future<void> undoRemove() async {
    final item = _lastRemoved;
    if (item == null) return;
    _lastRemoved = null;
    final items = [...state.items]
      ..insert(_lastRemovedIndex.clamp(0, state.items.length), item);
    await _update(items);
  }

  Future<void> placeOrder({required int userId}) async {
    if (state.isEmpty || state.checkout == CheckoutStatus.placing) return;
    emit(_copy(checkout: CheckoutStatus.placing));
    final result = await _placeOrder(userId: userId, items: state.items);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          CartState(
            isLoaded: true,
            checkout: CheckoutStatus.success,
            order: value,
          ),
        );
      case Err(:final failure):
        emit(_copy(checkout: CheckoutStatus.failure, failure: failure));
    }
  }

  /// Called when the confirmation screen is closed.
  void acknowledgeOrder() => emit(_copy(checkout: CheckoutStatus.idle));

  Future<void> _update(List<CartItem> items) async {
    if (items == state.items) return;
    _emitItems(items);
    await _saveCart(items);
  }

  void _emitItems(List<CartItem> items) {
    emit(CartState(items: items, summary: _summarise(items), isLoaded: true));
  }

  CartState _copy({required CheckoutStatus checkout, Failure? failure}) {
    return CartState(
      items: state.items,
      summary: state.summary,
      isLoaded: state.isLoaded,
      checkout: checkout,
      order: state.order,
      failure: failure,
    );
  }
}
