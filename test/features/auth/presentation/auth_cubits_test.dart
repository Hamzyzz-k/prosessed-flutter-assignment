import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

const _user = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
  image: '',
);

void main() {
  late _MockAuthRepository repository;
  late StreamController<void> expired;

  setUp(() {
    repository = _MockAuthRepository();
    expired = StreamController<void>.broadcast();
    when(() => repository.onSessionExpired).thenAnswer((_) => expired.stream);
    when(repository.logout).thenAnswer((_) async {});
  });

  tearDown(() => expired.close());

  AuthCubit buildAuth() => AuthCubit(
    GetStoredUser(repository),
    GetCurrentUser(repository),
    LogoutUser(repository, const []),
    WatchSessionExpired(repository),
  );

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'no stored session goes to login',
      setUp: () => when(repository.getStoredUser).thenAnswer((_) async => null),
      build: buildAuth,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const Unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'stored session opens the shop, then refreshes the user',
      setUp: () {
        when(repository.getStoredUser).thenAnswer((_) async => _user);
        when(repository.getCurrentUser).thenAnswer(
          (_) async => const Ok(
            User(
              id: 1,
              username: 'emilys',
              firstName: 'Emily',
              lastName: 'Johnson',
              email: 'emily@example.com',
              image: '',
              phone: '+81 965-431-3024',
            ),
          ),
        );
      },
      build: buildAuth,
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        const Authenticated(_user),
        isA<Authenticated>().having((s) => s.user.phone, 'phone', isNotNull),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'offline at launch keeps the stored session',
      setUp: () {
        when(repository.getStoredUser).thenAnswer((_) async => _user);
        when(repository.getCurrentUser)
            .thenAnswer((_) async => const Err(NetworkFailure()));
      },
      build: buildAuth,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const Authenticated(_user)],
    );

    blocTest<AuthCubit, AuthState>(
      'a session-expired event signs out with a reason',
      build: buildAuth,
      seed: () => const Authenticated(_user),
      act: (_) async {
        expired.add(null);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [const Unauthenticated(sessionExpired: true)],
    );

    blocTest<AuthCubit, AuthState>(
      'logout signs out without a reason',
      build: buildAuth,
      seed: () => const Authenticated(_user),
      act: (cubit) => cubit.logout(),
      expect: () => [const Unauthenticated()],
    );
  });

  group('LoginCubit', () {
    blocTest<LoginCubit, LoginState>(
      'submitting then success',
      setUp: () => when(
        () => repository.login(username: 'emilys', password: 'emilyspass'),
      ).thenAnswer((_) async => const Ok(_user)),
      build: () => LoginCubit(LoginUser(repository)),
      act: (cubit) => cubit.submit(username: 'emilys', password: 'emilyspass'),
      expect: () => [
        const LoginState(status: LoginStatus.submitting),
        const LoginState(status: LoginStatus.success, user: _user),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'wrong password ends in failure, typing clears it',
      setUp: () => when(
        () => repository.login(username: 'emilys', password: 'wrongpass'),
      ).thenAnswer((_) async => const Err(InvalidCredentialsFailure())),
      build: () => LoginCubit(LoginUser(repository)),
      act: (cubit) async {
        await cubit.submit(username: 'emilys', password: 'wrongpass');
        cubit.clearError();
      },
      expect: () => [
        const LoginState(status: LoginStatus.submitting),
        const LoginState(
          status: LoginStatus.failure,
          failure: InvalidCredentialsFailure(),
        ),
        const LoginState(),
      ],
    );
  });
}
