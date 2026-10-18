import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

import '../../../helpers/helpers.dart';

class _MockClient extends Mock implements ApiClient;

void main() {
  late InMemoryKeyValueStore store;
  late _MockClient client;
  late CartRepositoryImpl repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    client = _MockClient();
    repository = CartRepositoryImpl(
      CartLocalDataSourceImpl(store),
      CartRemoteDataSourceImpl(client),
    );
  });

  test('saved cart survives a restart', () async {
    await repository.saveCart([CartItem(product: product(), quantity: 2)]);

    final reopened = CartRepositoryImpl(
      CartLocalDataSourceImpl(store),
      CartRemoteDataSourceImpl(client),
    );
    final items = (await reopened.loadCart()).valueOrNull!;

    expect(items.single.quantity, 2);
    expect(items.single.product, product());
  });

  test('a corrupt saved cart is reported, not a crash', () async {
    store.values['cart.items'] = 'not json';

    final result = await repository.loadCart();

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('placeOrder posts id/quantity pairs and clears the cart', () async {
    await repository.saveCart([CartItem(product: product(), quantity: 2)]);
    when(() => client.post('/carts/add', body: any(named: 'body')))
        .thenAnswer((_) async => fixture('cart_add.json'));

    final result = await repository.placeOrder(
      userId: 1,
      items: [CartItem(product: product(), quantity: 2)],
    );

    final body =
        verify(() => client.post('/carts/add', body: captureAny(named: 'body')))
                .captured
                .single
            as Map<String, dynamic>;
    expect(body['userId'], 1);
    expect(body['products'], [
      {'id': 1, 'quantity': 2},
    ]);
    expect(result.valueOrNull?.id, 209);
    expect((await repository.loadCart()).valueOrNull, isEmpty);
  });

  test('a failed order keeps the saved cart', () async {
    await repository.saveCart([CartItem(product: product(), quantity: 1)]);
    when(() => client.post('/carts/add', body: any(named: 'body')))
        .thenThrow(const NetworkException());

    final result = await repository.placeOrder(
      userId: 1,
      items: [CartItem(product: product(), quantity: 1)],
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect((await repository.loadCart()).valueOrNull, hasLength(1));
  });
}
