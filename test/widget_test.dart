import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'portfolio_test_app.dart';

import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';

const _menuActions = [
  'Lihat Proyek',
  'Tambah Proyek',
  'Tambah Sertifikasi',
  'Logout',
];

Future<void> _tapMenuAction(WidgetTester tester, String action) async {
  final button = find.text(action);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();

  expect(
    find.descendant(
      of: find.byType(SnackBar),
      matching: find.text(
        action == 'Logout'
            ? 'Kamu berhasil logout.'
            : 'Kamu telah menekan tombol $action!',
      ),
    ),
    findsOneWidget,
  );
  expect(tester.takeException(), isNull);

  // Let the message disappear before interacting with another menu card.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  if (action != 'Logout') {
    final pageType = switch (action) {
      'Lihat Proyek' => ProjectListScreen,
      'Tambah Proyek' => ProjectFormPage,
      _ => CertificationFormPage,
    };
    expect(find.byType(pageType), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  }
}

void main() {
  testWidgets('Halaman awal menampilkan identitas dan menu portofolio', (
    tester,
  ) async {
    await tester.pumpWidget(portfolioTestApp(token: 'test-session'));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('MyPortfolio'),
      ),
      findsOneWidget,
    );
    for (final text in [
      '2506616711',
      'Umar Faiz Rahman',
      'PBP F',
      'Selamat datang di MyPortfolio Mobile!',
      ..._menuActions,
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    for (final icon in [
      Icons.folder,
      Icons.add_circle,
      Icons.workspace_premium,
      Icons.logout,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final action in _menuActions) {
    testWidgets('$action menampilkan SnackBar yang sesuai', (tester) async {
      await tester.pumpWidget(portfolioTestApp(token: 'test-session'));
      await _tapMenuAction(tester, action);
    });
  }

  for (final viewport in [
    (size: const Size(320, 568), textScale: 1.0),
    (size: const Size(844, 390), textScale: 1.0),
    (size: const Size(320, 568), textScale: 2.0),
  ]) {
    testWidgets(
      'Menu dapat digunakan pada ${viewport.size}, skala teks ${viewport.textScale}',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = viewport.size;
        tester.platformDispatcher.textScaleFactorTestValue = viewport.textScale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(portfolioTestApp(token: 'test-session'));
        expect(tester.takeException(), isNull);
        for (final action in _menuActions) {
          await _tapMenuAction(tester, action);
        }
      },
    );
  }
}
