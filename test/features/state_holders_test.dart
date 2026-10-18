import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';
import 'package:shopsphere/features/diagnostics/domain/repositories/diagnostics_repository.dart';
import 'package:shopsphere/features/diagnostics/presentation/cubit/error_lab_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shopsphere/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';
import 'package:shopsphere/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

import '../helpers/helpers.dart';

class _MockProductRepository extends Mock implements ProductRepository;

class _MockAuthRepository extends Mock implements AuthRepository;

class _MockDiagnostics extends Mock implements DiagnosticsRepository;

ProductDetails details({int stock = 3}) => ProductDetails(
  id: 1,
  title: 'Phone',
  price: 100,
  discountPercentage: 10,
  rating: 4.5,
  stock: stock,
  thumbnail: '',
  category: 'smartphones',
  description: 'A phone',
  images: const [],
  reviews: const [],
);

void main() {
  group('ProductDetailsCubit', () {
    late _MockProductRepository repository;

    setUp(() => repository = _MockProductRepository());

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'loads the product',
      setUp: () =>
          when(() => repository.getProduct(1))
              .thenAnswer((_) async => Ok(details())),
      build: () => ProductDetailsCubit(GetProductDetails(repository), 1),
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductDetailsLoading(),
        ProductDetailsLoaded(details()),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'unknown id is a not-found failure',
      setUp: () =>
          when(() => repository.getProduct(9999))
              .thenAnswer((_) async => const Err(NotFoundFailure())),
      build: () => ProductDetailsCubit(GetProductDetails(repository), 9999),
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [
        isA<ProductDetailsFailure>().having(
          (s) => s.isNotFound,
          'isNotFound',
          isTrue,
        ),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'quantity stays within 1..stock',
      build: () => ProductDetailsCubit(GetProductDetails(repository), 1),
      seed: () => ProductDetailsLoaded(details()),
      act: (cubit) => cubit
        ..setQuantity(10)
        ..setQuantity(0),
      expect: () => [
        ProductDetailsLoaded(details(), quantity: 3),
        ProductDetailsLoaded(details()),
      ],
    );
  });

  group('ProfileCubit', () {
    const user = User(
      id: 1,
      username: 'emilys',
      firstName: 'Emily',
      lastName: 'Johnson',
      email: 'e@x.com',
      image: '',
    );

    blocTest<ProfileCubit, ProfileState>(
      'loading then loaded',
      build: () {
        final repository = _MockAuthRepository();
        when(repository.getCurrentUser).thenAnswer((_) async => const Ok(user));
        return ProfileCubit(GetCurrentUser(repository));
      },
      act: (cubit) => cubit.load(),
      expect: () => [const ProfileLoading(), const ProfileLoaded(user)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'a failure is shown with retry',
      build: () {
        final repository = _MockAuthRepository();
        when(repository.getCurrentUser)
            .thenAnswer((_) async => const Err(TimeoutFailure()));
        return ProfileCubit(GetCurrentUser(repository));
      },
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [const ProfileFailure(TimeoutFailure())],
    );
  });

  group('SettingsCubit', () {
    test('defaults to system theme and English', () {
      final cubit = SettingsCubit(
        SettingsRepositoryImpl(InMemoryKeyValueStore()),
      );
      expect(cubit.state, const AppSettings());
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(cubit.state.locale, const Locale('en'));
    });

    test('remembers theme and language across launches', () async {
      final store = InMemoryKeyValueStore();
      final first = SettingsCubit(SettingsRepositoryImpl(store));
      await first.setTheme(ThemePreference.dark);
      await first.setLanguage(AppLanguage.hindi);

      final relaunched = SettingsCubit(SettingsRepositoryImpl(store));

      expect(relaunched.state.themeMode, ThemeMode.dark);
      expect(relaunched.state.locale, const Locale('hi'));
    });
  });

  group('WishlistCubit', () {
    test('toggle adds newest first, removes, and persists', () async {
      final store = InMemoryKeyValueStore();
      final cubit = WishlistCubit(WishlistRepositoryImpl(store));

      await cubit.toggle(product());
      await cubit.toggle(product(id: 2));
      expect(cubit.state.map((p) => p.id), [2, 1]);

      await cubit.toggle(product());
      expect(cubit.contains(1), isFalse);

      final reloaded = WishlistCubit(WishlistRepositoryImpl(store));
      await reloaded.load();
      expect(reloaded.state.single.id, 2);
    });

    test('logout cleaner wipes the wishlist', () async {
      final store = InMemoryKeyValueStore();
      final repository = WishlistRepositoryImpl(store);
      await WishlistCubit(repository).toggle(product());

      await repository.clearUserData();

      expect((await repository.load()).valueOrNull, isEmpty);
    });
  });

  group('ErrorLabCubit', () {
    blocTest<ErrorLabCubit, Map<LabScenario, LabOutcome>>(
      'records a handled failure for the 500 scenario',
      build: () {
        final repository = _MockDiagnostics();
        when(() => repository.run(LabScenario.serverError))
            .thenAnswer((_) async => const Err(ServerFailure(statusCode: 500)));
        return ErrorLabCubit(repository);
      },
      act: (cubit) => cubit.run(LabScenario.serverError),
      expect: () => [
        {LabScenario.serverError: const LabRunning()},
        {
          LabScenario.serverError: const LabHandled(
            ServerFailure(statusCode: 500),
          ),
        },
      ],
    );
  });

  test('window size classes follow the brief', () {
    expect(WindowSize.fromWidth(400), WindowSize.compact);
    expect(WindowSize.fromWidth(600), WindowSize.medium);
    expect(WindowSize.fromWidth(1024), WindowSize.medium);
    expect(WindowSize.fromWidth(1280), WindowSize.expanded);
    expect(productGridColumns(400), 2);
    expect(productGridColumns(700), 3);
    expect(productGridColumns(900), 4);
  });
}
