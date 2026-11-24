import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  test(
    'Login and logout call DRF and notify listeners on session changes',
    () async {
      final calls = <String>[];
      final client = ApiClient(
        client: MockClient((request) async {
          calls.add(request.url.path);
          expect(request.method, 'POST');
          if (request.url.path == '/api/v1/auth/token/') {
            expect(jsonDecode(request.body), {
              'username': 'student',
              'password': 'demo',
            });
            return http.Response('{"token":"sample"}', 200);
          }
          expect(request.headers['authorization'], 'Token sample');
          return http.Response('', 204);
        }),
      );
      final auth = AuthState(client);
      final states = <bool>[];
      auth.addListener(() => states.add(auth.isLoggedIn));
      await auth.login('student', 'demo');
      expect(auth.token, 'sample');
      await auth.logout();
      await auth.logout();
      expect(auth.token, isNull);
      expect(states, [true, false]);
      expect(calls, ['/api/v1/auth/token/', '/api/v1/auth/logout/']);
    },
  );

  test('Failed login leaves session anonymous', () async {
    final auth = AuthState(
      ApiClient(client: MockClient((_) async => http.Response('{}', 400))),
    );
    await expectLater(
      auth.login('student', 'wrong'),
      throwsA(isA<ApiException>()),
    );
    expect(auth.isLoggedIn, isFalse);
  });

  test(
    'Failed token revocation still clears local state and notifies',
    () async {
      final auth = AuthState(
        ApiClient(
          client: MockClient(
            (_) async => throw http.ClientException('offline'),
          ),
        ),
        initialToken: 'expired',
      );
      var notifications = 0;
      auth.addListener(() => notifications++);
      await expectLater(auth.logout(), throwsA(isA<http.ClientException>()));
      expect(auth.isLoggedIn, isFalse);
      expect(notifications, 1);
    },
  );
}
