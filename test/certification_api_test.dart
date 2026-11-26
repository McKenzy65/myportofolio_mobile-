import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const saved = {
    'id': 7,
    'title': 'Sertifikasi 🎓',
    'description': 'Kompetensi aplikasi mobile',
    'year': 2026,
    'is_highlight': true,
    'star_count': 2,
    'is_starred': false,
    'starred_by_names': 'nisa, umar',
  };

  ApiClient makeClient(MockClientHandler handle) {
    final client = ApiClient(client: MockClient(handle));
    addTearDown(client.close);
    return client;
  }

  test('Public list is a UTF-8 array and detail uses the numeric id', () async {
    final paths = <String>[];
    final client = makeClient((request) async {
      expect(request.method, 'GET');
      expect(request.headers['Authorization'], isNull);
      paths.add(request.url.path);
      final body = paths.length == 1 ? [saved] : saved;
      return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
    });

    final rows = await client.getCertifications();
    final detail = await client.getCertification(rows.single.id!);
    expect(paths, ['/api/v1/certifications/', '/api/v1/certifications/7/']);
    expect(rows.single.title, 'Sertifikasi 🎓');
    expect(detail.year, 2026);
    expect(detail.starCount, 2);
    expect(detail.starredByNames, 'nisa, umar');
  });

  test('An empty public array is a successful result', () async {
    final client = makeClient((request) async => http.Response('[]', 200));
    expect(await client.getCertifications(), isEmpty);
  });

  test(
    'POST sends only writable fields and returns canonical server data',
    () async {
      final client = makeClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/certifications/');
        expect(request.headers['Authorization'], 'Token session-key');
        expect(request.headers['Content-Type'], startsWith('application/json'));
        expect(jsonDecode(utf8.decode(request.bodyBytes)), {
          'title': '<b>Data</b>',
          'description': 'Kompetensi aplikasi mobile',
          'year': 2026,
          'is_highlight': true,
        });
        return http.Response.bytes(
          utf8.encode(jsonEncode({...saved, 'id': 11, 'title': 'Data'})),
          201,
        );
      });

      final copy = Certification.fromJson({...saved, 'title': '<b>Data</b>'});
      final result = await client.createCertification(
        copy,
        token: 'session-key',
      );
      expect(result.id, 11);
      expect(result.title, 'Data');
    },
  );

  test('Preserves 401 and 403 and maps 400 to field labels safely', () async {
    final responses = [
      http.Response('raw private text', 401),
      http.Response('raw private text', 403),
      http.Response(
        '{"title":["raw private text"],"year":["raw private text"]}',
        400,
      ),
      http.Response('<html>raw private text</html>', 400),
    ];
    final client = makeClient((request) async => responses.removeAt(0));
    const draft = Certification(title: 'Dart', description: 'Test', year: 2026);

    for (final status in [401, 403, 400, 400]) {
      final expectedMessage = status == 400 && responses.length == 2
          ? contains('judul, tahun')
          : isNot(contains('private'));
      await expectLater(
        client.createCertification(draft, token: 'test'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', status)
              .having((error) => error.message, 'message', expectedMessage),
        ),
      );
    }
  });

  test(
    'A missing detail is distinguishable from an empty collection',
    () async {
      final client = makeClient(
        (request) async => http.Response('Not found', 404),
      );
      await expectLater(
        client.getCertification(123),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            404,
          ),
        ),
      );
    },
  );
}
