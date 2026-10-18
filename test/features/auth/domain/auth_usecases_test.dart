import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/session/user_data_cleaner.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

class _MockCleaner extends Mock implements UserDataCleaner;

const _user = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
  image: '',
);

void main() {
  group('CredentialRules', () {
    test('username must be present and at least 3 characters', () {
      expect(CredentialRules.username(''), CredentialError.required);
      expect(CredentialRules.username('  '), CredentialError.required);
      expect(CredentialRules.username('em'), CredentialError.tooShort);
      expect(CredentialRules.username('emilys'), isNull);
    });

    test('password must be present and at least 6 characters', () {
      expect(CredentialRules.password(null), CredentialError.required);
      expect(CredentialRules.password('abc'), CredentialError.tooShort);
      expect(CredentialRules.password('emilyspass'), isNull);
    });
  });

  group('LoginUser', () {
    late _MockAuthRepository repository;

    setUp(() => repository = _MockAuthRepository());

    test('trims the username before calling the repository', () async {
      when(() => repository.login(username: 'emilys', password: 'emilyspass'))
          .thenAnswer((_) async => const Ok(_user));

      final result = await LoginUser(repository)(
        username: '  emilys ',
        password: 'emilyspass',
      );

      expect(result, const Ok(_user));
    });

    test('rejects invalid input without a network call', () async {
      final result = await LoginUser(repository)(username: 'e', password: '1');

      expect(result.failureOrNull, isA<InvalidCredentialsFailure>());
      verifyZeroInteractions(repository);
    });
  });

  group('LogoutUser', () {
    test('clears per-user data on a normal logout', () async {
      final repository = _MockAuthRepository();
      final cleaner = _MockCleaner();
      when(repository.logout).thenAnswer((_) async {});
      when(cleaner.clearUserData).thenAnswer((_) async {});

      await LogoutUser(repository, [cleaner])();

      verify(cleaner.clearUserData).called(1);
    });

    test('keeps per-user data when the session merely expired', () async {
      final repository = _MockAuthRepository();
      final cleaner = _MockCleaner();
      when(repository.logout).thenAnswer((_) async {});

      await LogoutUser(repository, [cleaner])(clearUserData: false);

      verifyNever(cleaner.clearUserData);
    });
  });
}
