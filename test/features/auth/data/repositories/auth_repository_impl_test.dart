import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/session/session_events.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../../helpers/helpers.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource;

void main() {
  late _MockRemote remote;
  late InMemoryTokenStorage tokens;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    tokens = InMemoryTokenStorage();
    repository = AuthRepositoryImpl(
      remote,
      AuthLocalDataSourceImpl(tokens, InMemoryKeyValueStore()),
      SessionEvents(),
    );
  });

  void stubLogin() => when(
    () => remote.login(username: 'emilys', password: 'emilyspass'),
  ).thenAnswer((_) async => LoginResponseModel.fromJson(fixture('login.json')));

  test('login stores tokens and the user', () async {
    stubLogin();

    final result = await repository.login(
      username: 'emilys',
      password: 'emilyspass',
    );

    expect(result.valueOrNull?.username, 'emilys');
    expect(tokens.access, 'fake-access-token');
    expect(tokens.refresh, 'fake-refresh-token');
    expect((await repository.getStoredUser())?.id, 1);
  });

  test('400 from login becomes InvalidCredentialsFailure', () async {
    when(() => remote.login(username: 'emilys', password: 'wrongpass'))
        .thenThrow(const BadRequestException('Invalid credentials'));

    final result = await repository.login(
      username: 'emilys',
      password: 'wrongpass',
    );

    expect(result.failureOrNull, isA<InvalidCredentialsFailure>());
    expect(tokens.access, isNull);
  });

  test('no network on login becomes NetworkFailure', () async {
    when(() => remote.login(username: 'emilys', password: 'emilyspass'))
        .thenThrow(const NetworkException());

    final result = await repository.login(
      username: 'emilys',
      password: 'emilyspass',
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('getCurrentUser maps 401 to SessionExpiredFailure', () async {
    when(remote.getMe).thenThrow(const UnauthorizedException());

    final result = await repository.getCurrentUser();

    expect(result.failureOrNull, isA<SessionExpiredFailure>());
  });

  test('getCurrentUser refreshes the stored profile', () async {
    stubLogin();
    await repository.login(username: 'emilys', password: 'emilyspass');
    when(remote.getMe)
        .thenAnswer((_) async => UserModel.fromJson(fixture('me.json')));

    await repository.getCurrentUser();

    expect((await repository.getStoredUser())?.phone, isNotNull);
  });

  test('logout clears the session', () async {
    stubLogin();
    await repository.login(username: 'emilys', password: 'emilyspass');

    await repository.logout();

    expect(await repository.getStoredUser(), isNull);
    expect(tokens.refresh, isNull);
  });
}
