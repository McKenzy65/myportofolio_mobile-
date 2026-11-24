import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const project = Project(
    title: 'Portofolio',
    description: 'Pengembangan aplikasi',
    techStack: 'Dart',
    projectUrl: 'https://example.org',
  );

  test('Guest list reads UTF-8 JSON even without a charset header', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['authorization'], isNull);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {
                ...project.toJson(),
                'title': 'Portofolio \u{1f4bb}',
                'id': 'uuid',
              },
            ]),
          ),
          200,
        );
      }),
    );
    final projects = await client.getProjects();
    expect(projects.single.title, 'Portofolio \u{1f4bb}');
    expect(projects.single.id, 'uuid');
  });

  test('Authenticated POST sends only writable fields and returns the created project', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['authorization'], 'Token abc');
        expect(request.headers['content-type'], startsWith('application/json'));
        expect(jsonDecode(request.body), project.toJson());
        return http.Response(
          jsonEncode({...project.toJson(), 'id': 'created'}),
          201,
        );
      }),
    );
    expect((await client.createProject(project, token: 'abc')).id, 'created');
  });

  test('HTTP errors expose status without internal server content', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response('<html>private error details</html>', 500),
      ),
    );
    await expectLater(
      client.getProjects(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 500)
            .having((e) => e.message, 'message', isNot(contains('private'))),
      ),
    );
  });

  test(
    'Token endpoint rejects a successful response with an empty token',
    () async {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('{"token":""}', 200)),
      );
      await expectLater(
        client.obtainToken('user', 'password'),
        throwsFormatException,
      );
    },
  );
}
