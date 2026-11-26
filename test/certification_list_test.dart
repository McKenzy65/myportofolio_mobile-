import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'portfolio_test_app.dart';

const _entries = [
  {
    'id': 72,
    'title': 'Flutter Associate',
    'description': 'Pemrograman mobile',
    'year': 2026,
    'is_highlight': true,
    'star_count': 3,
    'is_starred': false,
    'starred_by_names': 'user_a, user_b, user_c',
  },
  {
    'id': 19,
    'title': 'Basis Data',
    'description': 'Pemodelan relasional',
    'year': 2024,
    'is_highlight': false,
    'star_count': 0,
    'is_starred': false,
    'starred_by_names': '',
  },
];

http.Response _json(Object value) =>
    http.Response.bytes(utf8.encode(jsonEncode(value)), 200);

void main() {
  testWidgets(
    'Daftar publik menangani loading, error, retry, kosong dan tarik untuk memuat ulang',
    (tester) async {
      final first = Completer<http.Response>();
      var requests = 0;
      final api = ApiClient(
        client: MockClient((r) async {
          expect(r.method, 'GET');
          expect(r.url.path, '/api/v1/certifications/');
          expect(r.headers.containsKey('Authorization'), isFalse);
          requests++;
          if (requests == 1) return first.future;
          if (requests == 2) return _json([]);
          return _json(_entries);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        portfolioTestScreen(const CertificationListScreen(), client: api),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      expect(requests, 1);
      first.complete(http.Response('private diagnostics', 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('private diagnostics'), findsNothing);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada sertifikasi.'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 450));
      await tester.pumpAndSettle();
      expect(find.text('Flutter Associate'), findsOneWidget);
      expect(requests, 3);
    },
  );

  testWidgets(
    'Pencarian, filter unggulan, dan hapus pencarian memakai data yang sudah dimuat',
    (tester) async {
      var requests = 0;
      final api = ApiClient(
        client: MockClient((r) async {
          requests++;
          return _json(_entries);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        portfolioTestScreen(const CertificationListScreen(), client: api),
      );
      await tester.pumpAndSettle();
      final input = find.byType(TextField);
      await tester.enterText(input, ' RELASIONAL ');
      await tester.pumpAndSettle();
      expect(find.text('Basis Data'), findsOneWidget);
      expect(find.text('Flutter Associate'), findsNothing);
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada sertifikasi yang cocok.'), findsOneWidget);
      await tester.tap(find.byTooltip('Hapus pencarian'));
      await tester.pumpAndSettle();
      expect(find.text('Flutter Associate'), findsOneWidget);
      expect(find.text('Basis Data'), findsNothing);
      await tester.tap(find.byType(FilterChip));
      await tester.enterText(input, '2024');
      await tester.pumpAndSettle();
      expect(find.text('Basis Data'), findsOneWidget);
      expect(find.text('Flutter Associate'), findsNothing);
      expect(requests, 1);
    },
  );

  testWidgets(
    'Detail publik mengambil ID yang diketuk, menangani 404 dan menampilkan seluruh nilai terbaru',
    (tester) async {
      final paths = <String>[];
      var detailRequests = 0;
      final api = ApiClient(
        client: MockClient((r) async {
          expect(r.headers.containsKey('Authorization'), isFalse);
          paths.add(r.url.path);
          if (r.url.path == '/api/v1/certifications/') return _json(_entries);
          expect(r.url.path, '/api/v1/certifications/72/');
          detailRequests++;
          if (detailRequests == 1) return http.Response('', 404);
          return _json({..._entries.first, 'description': 'Deskripsi terbaru'});
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        portfolioTestScreen(const CertificationListScreen(), client: api),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flutter Associate'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sertifikasi ini sudah tidak tersedia.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      for (final value in [
        'Detail Sertifikasi',
        'Flutter Associate',
        'Deskripsi terbaru',
        'ID: 72',
        'Tahun: 2026',
        'Unggulan: Ya',
        'Jumlah bintang: 3',
        'Ditandai pada akses publik: Tidak',
        'Pemberi bintang: user_a, user_b, user_c',
      ]) {
        expect(find.text(value), findsOneWidget);
      }
      expect(paths, [
        '/api/v1/certifications/',
        '/api/v1/certifications/72/',
        '/api/v1/certifications/72/',
      ]);
    },
  );

  testWidgets('Pengunjung dapat membuka daftar dari kartu dan drawer', (
    tester,
  ) async {
    await tester.pumpWidget(portfolioTestApp());
    await tester.ensureVisible(find.text('Lihat Sertifikasi'));
    await tester.tap(find.text('Lihat Sertifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada sertifikasi.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Certifications'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Sertifikasi'), findsOneWidget);
    expect(find.text('Belum ada sertifikasi.'), findsOneWidget);
  });
}
