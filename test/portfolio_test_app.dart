import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

Future<http.Response> portfolioResponse(http.Request request) async {
  return switch ((request.method, request.url.path)) {
    ('GET', '/api/v1/certifications/') => http.Response('[]', 200),
    ('POST', '/api/v1/certifications/') => http.Response(
      jsonEncode({
        ...jsonDecode(request.body) as Map<String, dynamic>,
        'id': 17,
        'star_count': 0,
        'is_starred': false,
        'starred_by_names': '',
      }),
      201,
    ),
    ('GET', '/api/v1/projects/') => http.Response('[]', 200),
    ('POST', '/api/v1/projects/') => http.Response(
      jsonEncode({
        ...jsonDecode(request.body) as Map<String, dynamic>,
        'id': '21ec9d53-15e8-4fb5-8a83-b5e8b7ed67ae',
      }),
      201,
    ),
    ('POST', '/api/v1/auth/token/') => http.Response(
      '{"token":"test-session"}',
      200,
    ),
    ('POST', '/api/v1/auth/logout/') => http.Response('', 204),
    _ => throw StateError(
      'Unexpected request: ${request.method} ${request.url.path}',
    ),
  };
}

MyApp portfolioTestApp({
  String? token,
  MockClientHandler handle = portfolioResponse,
}) {
  final api = ApiClient(client: MockClient(handle));
  addTearDown(api.close);
  return MyApp(apiClient: api, initialToken: token);
}

Widget portfolioTestScreen(Widget screen, {ApiClient? client, String? token}) {
  final api = client ?? ApiClient(client: MockClient(portfolioResponse));
  if (client == null) addTearDown(api.close);
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: token),
      ),
    ],
    child: MaterialApp(home: screen),
  );
}
