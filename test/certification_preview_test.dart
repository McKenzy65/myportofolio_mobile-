import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'portfolio_test_app.dart';

import 'package:myportofolio_mobile/screens/certification_form.dart';

Finder field(String name) => find.byKey(ValueKey('certification-$name'));
Finder previewText(String text) =>
    find.descendant(of: field('preview'), matching: find.text(text));

Future<void> enter(WidgetTester tester, String name, String text) async {
  await tester.ensureVisible(field(name));
  await tester.pumpAndSettle();
  await tester.enterText(field(name), text);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Counter mengikuti Unicode dan trim tanpa memotong input salah', (
    tester,
  ) async {
    await tester.pumpWidget(portfolioTestScreen(const CertificationFormPage()));
    expect(find.text('0/255'), findsOneWidget);
    await enter(tester, 'title', '  A🎓  ');
    expect(find.text('2/255'), findsOneWidget);
    await enter(tester, 'title', 'a' * 256);
    expect(find.text('256/255'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('title')).controller!.text.length,
      256,
    );
    await enter(tester, 'title', '');
    expect(find.text('0/255'), findsOneWidget);
  });

  testWidgets('Pratinjau mengikuti input dan sakelar sebelum Simpan', (
    tester,
  ) async {
    await tester.pumpWidget(portfolioTestScreen(const CertificationFormPage()));
    expect(previewText('Judul sertifikasi kamu'), findsOneWidget);
    await enter(tester, 'title', '  Flutter Dasar  ');
    await enter(tester, 'description', 'Sertifikat pemrograman');
    await enter(tester, 'year', '002026');
    expect(previewText('Flutter Dasar'), findsOneWidget);
    expect(previewText('Sertifikat pemrograman'), findsOneWidget);
    expect(previewText('Tahun 2026'), findsOneWidget);
    await tester.ensureVisible(field('highlight'));
    await tester.pumpAndSettle();
    await tester.tap(field('highlight'));
    await tester.pumpAndSettle();
    expect(previewText('Unggulan'), findsOneWidget);
    await tester.tap(field('highlight'));
    await tester.pumpAndSettle();
    expect(previewText('Unggulan'), findsNothing);
    await enter(tester, 'title', 'Dart');
    await enter(tester, 'year', '-1');
    expect(previewText('Flutter Dasar'), findsNothing);
    expect(previewText('Dart'), findsOneWidget);
    expect(previewText('Tahun belum valid'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pratinjau panjang tetap terbaca pada ponsel dengan teks 200%', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(portfolioTestScreen(const CertificationFormPage()));
    await enter(tester, 'title', 'Sertifikasi Flutter ' * 12);
    await enter(tester, 'description', 'Pengalaman belajar Flutter. ' * 30);
    await tester.ensureVisible(field('highlight'));
    await tester.pumpAndSettle();
    await tester.tap(field('highlight'));
    await tester.ensureVisible(
      previewText('Pratinjau ini belum menyimpan data.'),
    );
    await tester.pumpAndSettle();
    expect(
      previewText('Pratinjau ini belum menyimpan data.').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
