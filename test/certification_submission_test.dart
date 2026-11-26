import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'portfolio_test_app.dart';

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillDraft(WidgetTester tester) async {
  await tap(tester, find.text('Tambah Sertifikasi'));
  for (final field in const {
    'title': '  <b>Flutter</b>  ',
    'description': '  Sertifikat PBP  ',
    'year': '002026',
  }.entries) {
    final finder = find.byKey(ValueKey('certification-${field.key}'));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, field.value);
    await tester.pumpAndSettle();
  }
}

Future<void> logIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'pemilik');
  await tester.enterText(find.byType(TextFormField).last, 'password uji');
  await tap(tester, find.widgetWithText(FilledButton, 'Login'));
}

void main() {
  testWidgets('Login yang dibatalkan tidak mengirim atau menghapus draf', (
    tester,
  ) async {
    final requests = <String>[];
    await tester.pumpWidget(
      portfolioTestApp(
        handle: (request) {
          requests.add(request.url.path);
          return portfolioResponse(request);
        },
      ),
    );
    await fillDraft(tester);
    await tap(tester, find.text('Simpan'));
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    expect(find.byType(CertificationFormPage), findsOneWidget);
    final title = tester.widget<TextFormField>(
      find.byKey(const Key('certification-title')),
    );
    expect(title.controller!.text, '  <b>Flutter</b>  ');
    await tap(tester, find.text('Simpan'));
    await logIn(tester);
    expect(requests, ['/api/v1/auth/token/', '/api/v1/certifications/']);
    expect(find.text('Ringkasan Sertifikasi'), findsOneWidget);
  });

  testWidgets(
    '401 dan 403 menjaga draf; 201 menampilkan respons dan daftar baru',
    (tester) async {
      final attempts = <String?>[];
      final records = <Map<String, dynamic>>[];
      var publicReads = 0;
      await tester.pumpWidget(
        portfolioTestApp(
          token: 'kedaluwarsa',
          handle: (request) async {
            if (request.url.path != '/api/v1/certifications/')
              return portfolioResponse(request);
            if (request.method == 'GET') {
              publicReads++;
              expect(request.headers.containsKey('Authorization'), isFalse);
              return http.Response(jsonEncode(records), 200);
            }
            attempts.add(request.headers['Authorization']);
            expect(jsonDecode(request.body), {
              'title': '<b>Flutter</b>',
              'description': 'Sertifikat PBP',
              'year': 2026,
              'is_highlight': false,
            });
            if (attempts.length == 1) return http.Response('', 401);
            if (attempts.length == 2) return http.Response('', 403);
            final saved = {
              ...jsonDecode(request.body) as Map<String, dynamic>,
              'title': 'Flutter',
              'id': 19,
            };
            records.add(saved);
            return http.Response(jsonEncode(saved), 201);
          },
        ),
      );

      await fillDraft(tester);
      await tap(tester, find.text('Simpan'));
      expect(
        tester.element(find.byType(LoginScreen)).read<AuthState>().token,
        isNull,
      );
      await logIn(tester);
      expect(attempts, ['Token kedaluwarsa']);
      await tap(tester, find.text('Simpan'));
      expect(find.textContaining('HTTP 403'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      final title = tester.widget<TextFormField>(
        find.byKey(const Key('certification-title')),
      );
      expect(title.controller!.text, '  <b>Flutter</b>  ');
      await tap(tester, find.text('Simpan'));
      expect(attempts, [
        'Token kedaluwarsa',
        'Token test-session',
        'Token test-session',
      ]);
      expect(find.text('Judul: Flutter'), findsOneWidget);
      await tap(tester, find.text('Lihat daftar'));
      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(publicReads, 1);
    },
  );

  testWidgets(
    'Ketukan Simpan ganda dan Back saat POST hanya membuat satu entri',
    (tester) async {
      final delayed = Completer<http.Response>();
      var writes = 0;
      await tester.pumpWidget(
        portfolioTestApp(
          token: 'aktif',
          handle: (request) {
            if (request.url.path == '/api/v1/certifications/' &&
                request.method == 'POST') {
              writes++;
              return delayed.future;
            }
            return portfolioResponse(request);
          },
        ),
      );
      await fillDraft(tester);
      final save = find.text('Simpan');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      delayed.complete(
        http.Response(
          '{"id":8,"title":"Flutter","description":"PBP","year":2026}',
          201,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Judul: Flutter'), findsOneWidget);
      await tap(tester, find.text('Tutup'));
      expect(find.text('Simpan'), findsNothing);
      expect(find.text('Tambah lagi'), findsOneWidget);
    },
  );
}
