import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';

Finder _field(String key) => find.byKey(ValueKey(key));

Future<void> _openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CertificationFormPage()));
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  await tester.ensureVisible(_field(key));
  await tester.pumpAndSettle();
  await tester.enterText(_field(key), value);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  expect(find.text('Simpan').hitTestable(), findsOneWidget);
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

bool _hasError(WidgetTester tester, String key) =>
    tester.state<FormFieldState<String>>(_field(key)).hasError;

Future<void> _fillRequired(WidgetTester tester) async {
  await _enter(tester, 'certification-title', 'Flutter Dasar');
  await _enter(tester, 'certification-description', 'Sertifikat pemrograman');
  await _enter(tester, 'certification-year', '2026');
}

void main() {
  testWidgets(
    'Ringkasan memuat semua nilai terbaru dan Tutup mempertahankan isian',
    (tester) async {
      await _openForm(tester);
      await _save(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await _enter(tester, 'certification-title', '  Flutter Dasar  ');
      await _enter(
        tester,
        'certification-description',
        '  Sertifikat pemrograman  ',
      );
      await _enter(tester, 'certification-year', ' 002026 ');
      await tester.ensureVisible(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await tester.tap(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await _save(tester);
      expect(find.text('Ringkasan Sertifikasi'), findsOneWidget);
      for (final text in [
        'Judul: Flutter Dasar',
        'Deskripsi: Sertifikat pemrograman',
        'Tahun: 2026',
        'Unggulan: Ya',
      ]) {
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(text),
          ),
          findsOneWidget,
        );
      }
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester
            .widget<TextFormField>(_field('certification-title'))
            .controller!
            .text,
        '  Flutter Dasar  ',
      );
      expect(
        tester.widget<SwitchListTile>(_field('certification-highlight')).value,
        isTrue,
      );
      await _enter(tester, 'certification-title', 'Dart Lanjutan');
      await _enter(tester, 'certification-description', 'Materi lanjutan');
      await _enter(tester, 'certification-year', '2025');
      await tester.ensureVisible(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await tester.tap(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await _save(tester);
      for (final text in [
        'Judul: Dart Lanjutan',
        'Deskripsi: Materi lanjutan',
        'Tahun: 2025',
        'Unggulan: Tidak',
      ]) {
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(text),
          ),
          findsOneWidget,
        );
      }
      expect(find.text('Judul: Flutter Dasar'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Form sertifikasi dapat digulir dengan keyboard dan font $scale',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 568);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _openForm(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        await _fillRequired(tester);
        await _save(tester);
        expect(tester.takeException(), isNull);
        expect(_hasError(tester, 'certification-year'), isFalse);
      },
    );
  }

  testWidgets('Sertifikasi menolak input wajib kosong atau hanya spasi', (
    tester,
  ) async {
    await _openForm(tester);
    for (final value in ['', '   ']) {
      for (final key in [
        'certification-title',
        'certification-description',
        'certification-year',
      ]) {
        await _enter(tester, key, value);
      }
      await _save(tester);
      for (final key in [
        'certification-title',
        'certification-description',
        'certification-year',
      ]) {
        expect(_hasError(tester, key), isTrue, reason: '$key wajib diisi');
      }
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Judul 256 karakter ditolak dan 255 setelah trim diterima', (
    tester,
  ) async {
    await _openForm(tester);
    await _fillRequired(tester);
    await _enter(tester, 'certification-title', 'a' * 256);
    await _save(tester);
    expect(_hasError(tester, 'certification-title'), isTrue);
    expect(find.byType(AlertDialog), findsNothing);
    await _enter(tester, 'certification-title', '  ${'a' * 255}  ');
    await _save(tester);
    expect(_hasError(tester, 'certification-title'), isFalse);
  });

  testWidgets('Tahun noninteger, negatif, dan melebihi batas model ditolak', (
    tester,
  ) async {
    await _openForm(tester);
    await _fillRequired(tester);
    for (final year in ['abc', '20.5', '-1', '2147483648']) {
      await _enter(tester, 'certification-year', year);
      await _save(tester);
      expect(
        _hasError(tester, 'certification-year'),
        isTrue,
        reason: 'Tahun $year harus ditolak',
      );
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  for (final year in ['0', '2147483647']) {
    testWidgets('Tahun batas $year diterima sesuai PositiveIntegerField', (
      tester,
    ) async {
      await _openForm(tester);
      await _fillRequired(tester);
      await _enter(tester, 'certification-year', year);
      await _save(tester);
      for (final key in [
        'certification-title',
        'certification-description',
        'certification-year',
      ]) {
        expect(_hasError(tester, key), isFalse);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Opsi unggulan dapat diaktifkan dan dinonaktifkan', (
    tester,
  ) async {
    await _openForm(tester);
    final highlight = _field('certification-highlight');
    await tester.ensureVisible(highlight);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(highlight).value, isFalse);
    await tester.tap(highlight);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(highlight).value, isTrue);
    await tester.tap(highlight);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(highlight).value, isFalse);
  });
}
