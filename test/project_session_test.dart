import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'portfolio_test_app.dart';

Future<void> tapText(WidgetTester tester, String label) async {
  final target = label == 'Login'
      ? find.widgetWithText(FilledButton, 'Login')
      : find.text(label).last;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> drawer(WidgetTester tester, String option) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tapText(tester, option);
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'demo');
  await tester.enterText(find.byType(TextFormField).last, ' demo password ');
  await tapText(tester, 'Login');
}

Future<void> fillProject(WidgetTester tester) async {
  for (final entry in const {
    'project-name': 'Proyek PBP',
    'project-description': 'Dibuat lewat Flutter',
    'project-technologies': 'Flutter',
    'project-link': 'https://example.org/proyek',
  }.entries) {
    final field = find.byKey(ValueKey(entry.key));
    await tester.ensureVisible(field);
    await tester.enterText(field, entry.value);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'Kartu dan drawer meminta login; batal tetap di Home; logout mencabut sesi',
    (tester) async {
      var loginAttempts = 0;
      var loggedOut = false;
      await tester.pumpWidget(
        portfolioTestApp(
          handle: (request) async {
            if (request.url.path.endsWith('/token/')) {
              loginAttempts++;
              expect(jsonDecode(request.body), {
                'username': 'demo',
                'password': ' demo password ',
              });
              if (loginAttempts == 1) {
                return http.Response('{"detail":"private"}', 400);
              }
            }
            if (request.url.path.endsWith('/logout/')) {
              expect(request.headers['Authorization'], 'Token test-session');
              loggedOut = true;
            }
            return portfolioResponse(request);
          },
        ),
      );
      await tapText(tester, 'Tambah Proyek');
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('MyPortfolio'), findsOneWidget);
      await drawer(tester, 'Add Project');
      await tapText(tester, 'Login');
      expect(find.text('Username wajib diisi.'), findsOneWidget);
      expect(loginAttempts, 0);
      await login(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.textContaining('HTTP 400'), findsOneWidget);
      expect(find.textContaining('private'), findsNothing);
      await login(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await drawer(tester, 'Logout');
      expect(find.text('MyPortfolio'), findsOneWidget);
      expect(loggedOut, isTrue);
      await tapText(tester, 'Tambah Proyek');
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    '401 mempertahankan draf, meminta login ulang; 403 tidak dianggap sukses',
    (tester) async {
      final projectTokens = <String>[];
      await tester.pumpWidget(
        portfolioTestApp(
          token: 'expired',
          handle: (request) async {
            if (request.url.path.endsWith('/projects/')) {
              projectTokens.add(request.headers['Authorization']!);
              expect(jsonDecode(request.body)['project_image_url'], '');
              if (projectTokens.length == 1) return http.Response('', 401);
              if (projectTokens.length == 2) return http.Response('', 403);
            }
            return portfolioResponse(request);
          },
        ),
      );
      await tapText(tester, 'Tambah Proyek');
      await fillProject(tester);
      await tapText(tester, 'Save');
      expect(find.byType(LoginScreen), findsOneWidget);
      await login(tester);
      expect(find.text('Proyek PBP'), findsOneWidget);
      expect(projectTokens, ['Token expired']);
      await tapText(tester, 'Save');
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('HTTP 403'), findsOneWidget);
      await tapText(tester, 'Save');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(projectTokens, [
        'Token expired',
        'Token test-session',
        'Token test-session',
      ]);
    },
  );

  testWidgets('Membuka rute form langsung tetap meminta login', (tester) async {
    await tester.pumpWidget(portfolioTestApp());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(ProjectFormPage.routeName);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });
}
