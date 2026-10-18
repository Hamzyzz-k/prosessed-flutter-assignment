import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';

import '../../../helpers/helpers.dart';

class _MockCartRepository extends Mock implements CartRepository;

void main() {
  late _MockCartRepository repository;

  const order = OrderConfirmation(
    id: 209,
    total: 200,
    discountedTotal: 180,
    totalQuantity: 2,
  );

  setUpAll(() => registerFallbackValue(<CartItem>[]));

  setUp(() {
    repository = _MockCartRepository();
    when(() => repository.saveCart(any()))
        .thenAnswer((_) async => const Ok(null));
    when(repository.loadCart).thenAnswer((_) async => const Ok([]));
  });

  CartCubit build() => CartCubit(
    LoadCart(repository),
    SaveCart(repository),
    const CalculateCartSummary(),
    PlaceOrder(repository),
  );

  blocTest<CartCubit, CartState>(
    'restores the saved cart on load',
    setUp: () => when(
      repository.loadCart,
    ).thenAnswer((_) async => Ok([CartItem(product: product(), quantity: 2)])),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.isLoaded, isTrue);
      expect(cubit.state.summary.itemCount, 2);
    },
  );

  blocTest<CartCubit, CartState>(
    'add updates the badge count and persists',
    build: build,
    act: (cubit) async {
      await cubit.add(product(), quantity: 2);
      await cubit.add(product(id: 2));
    },
    verify: (cubit) {
      expect(cubit.state.summary.itemCount, 3);
      verify(() => repository.saveCart(any())).called(2);
    },
  );

  blocTest<CartCubit, CartState>(
    'remove then undo puts the line back in place',
    build: build,
    act: (cubit) async {
      await cubit.add(product());
      await cubit.add(product(id: 2));
      await cubit.remove(1);
      await cubit.undoRemove();
    },
    verify: (cubit) {
      expect(cubit.state.items.map((i) => i.product.id), [1, 2]);
    },
  );

  blocTest<CartCubit, CartState>(
    'placeOrder empties the cart and keeps the confirmation',
    setUp: () =>
        when(() => repository.placeOrder(userId: 1, items: any(named: 'items')))
            .thenAnswer((_) async => const Ok(order)),
    build: build,
    seed: () {
      final items = [CartItem(product: product(), quantity: 2)];
      return CartState(
        items: items,
        summary: CartSummary.of(items),
        isLoaded: true,
      );
    },
    act: (cubit) => cubit.placeOrder(userId: 1),
    expect: () => [
      isA<CartState>().having(
        (s) => s.checkout,
        'checkout',
        CheckoutStatus.placing,
      ),
      isA<CartState>()
          .having((s) => s.checkout, 'checkout', CheckoutStatus.success)
          .having((s) => s.items, 'items', isEmpty)
          .having((s) => s.order, 'order', order)
          .having((s) => s.orderSummary?.total, 'confirmed total', 180),
    ],
  );

  blocTest<CartCubit, CartState>(
    'a failed order keeps the items and reports the failure',
    setUp: () =>
        when(() => repository.placeOrder(userId: 1, items: any(named: 'items')))
            .thenAnswer((_) async => const Err(NetworkFailure())),
    build: build,
    seed: () => CartState(
      items: [CartItem(product: product(), quantity: 1)],
      isLoaded: true,
    ),
    act: (cubit) => cubit.placeOrder(userId: 1),
    skip: 1,
    expect: () => [
      isA<CartState>()
          .having((s) => s.checkout, 'checkout', CheckoutStatus.failure)
          .having((s) => s.items, 'items', hasLength(1))
          .having((s) => s.failure, 'failure', const NetworkFailure()),
    ],
  );
}
