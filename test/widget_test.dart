import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

const _menuActions = ['Lihat Proyek', 'Tambah Proyek', 'Logout'];

Future<void> _tapMenuAction(WidgetTester tester, String action) async {
  final button = find.text(action);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();

  expect(
    find.descendant(
      of: find.byType(SnackBar),
      matching: find.text('Kamu telah menekan tombol $action!'),
    ),
    findsOneWidget,
  );
  expect(tester.takeException(), isNull);

  // Let the message disappear before interacting with another menu card.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Halaman awal menampilkan identitas dan menu portofolio', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

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
    for (final icon in [Icons.folder, Icons.add_circle, Icons.logout]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final action in _menuActions) {
    testWidgets('$action menampilkan SnackBar yang sesuai', (tester) async {
      await tester.pumpWidget(const MyApp());
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

        await tester.pumpWidget(const MyApp());
        expect(tester.takeException(), isNull);
        for (final action in _menuActions) {
          await _tapMenuAction(tester, action);
        }
      },
    );
  }
}
