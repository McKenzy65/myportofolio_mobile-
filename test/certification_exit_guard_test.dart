import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'portfolio_test_app.dart';

import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Finder _field(String key) => find.byKey(ValueKey(key));

Future<void> _openCertification(WidgetTester tester) async {
  await tester.pumpWidget(portfolioTestApp(token: 'test-session'));
  await tester.ensureVisible(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  await tester.ensureVisible(_field(key));
  await tester.pumpAndSettle();
  await tester.enterText(_field(key), value);
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> _chooseDrawer(WidgetTester tester, String destination) async {
  await _openDrawer(tester);
  await tester.tap(find.text(destination));
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _chooseConfirmation(WidgetTester tester, String action) async {
  expect(find.text('Tinggalkan formulir?'), findsOneWidget);
  await tester.ensureVisible(find.text(action));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

String _value(WidgetTester tester, String key) =>
    tester.widget<TextFormField>(_field(key)).controller!.text;

NavigatorState _navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

void _expectHome(WidgetTester tester) {
  expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  expect(find.byType(CertificationFormPage), findsNothing);
  expect(find.text('Tinggalkan formulir?'), findsNothing);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'Form kosong dan isian yang dikembalikan ke awal boleh langsung Back',
    (tester) async {
      await _openCertification(tester);
      await _back(tester);
      _expectHome(tester);

      await tester.ensureVisible(find.text('Tambah Sertifikasi'));
      await tester.tap(find.text('Tambah Sertifikasi'));
      await tester.pumpAndSettle();
      await _enter(tester, 'certification-title', 'Draf sementara');
      await _enter(tester, 'certification-title', '');
      await tester.ensureVisible(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await tester.tap(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await tester.tap(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await _back(tester);
      _expectHome(tester);
    },
  );

  testWidgets('Isian hanya spasi tetap meminta konfirmasi keluar', (
    tester,
  ) async {
    await _openCertification(tester);
    await _enter(tester, 'certification-title', '   ');
    await _back(tester);
    await _chooseConfirmation(tester, 'Lanjut mengisi');
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(_value(tester, 'certification-title'), '   ');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Batal Back mempertahankan semua isian dan konfirmasi mengizinkan keluar',
    (tester) async {
      await _openCertification(tester);
      await _enter(tester, 'certification-title', '  Flutter Dasar  ');
      await _enter(
        tester,
        'certification-description',
        '  Sertifikat pemrograman  ',
      );
      await _enter(tester, 'certification-year', '002026');
      await tester.ensureVisible(_field('certification-highlight'));
      await tester.pumpAndSettle();
      await tester.tap(_field('certification-highlight'));
      await tester.pumpAndSettle();

      await _back(tester);
      await _chooseConfirmation(tester, 'Lanjut mengisi');
      expect(_value(tester, 'certification-title'), '  Flutter Dasar  ');
      expect(
        _value(tester, 'certification-description'),
        '  Sertifikat pemrograman  ',
      );
      expect(_value(tester, 'certification-year'), '002026');
      expect(
        tester.widget<SwitchListTile>(_field('certification-highlight')).value,
        isTrue,
      );

      await _back(tester);
      await _chooseConfirmation(tester, 'Buang isian');
      _expectHome(tester);
    },
  );

  testWidgets(
    'Sertifikasi yang sudah diterima server boleh ditutup tanpa membuang draf',
    (tester) async {
      await _openCertification(tester);
      await _enter(tester, 'certification-title', 'Flutter Dasar');
      await _enter(
        tester,
        'certification-description',
        'Sertifikat pemrograman',
      );
      await _enter(tester, 'certification-year', '2026');
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Ringkasan Sertifikasi'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      await _back(tester);
      _expectHome(tester);
    },
  );

  for (final destination in ['Home', 'Add Project']) {
    testWidgets(
      'Drawer $destination menghormati batal dan persetujuan keluar',
      (tester) async {
        await _openCertification(tester);
        await _enter(tester, 'certification-title', 'Draf penting');
        await _chooseDrawer(tester, destination);
        await _chooseConfirmation(tester, 'Lanjut mengisi');
        expect(find.byType(CertificationFormPage), findsOneWidget);
        expect(_value(tester, 'certification-title'), 'Draf penting');

        await _chooseDrawer(tester, destination);
        await _chooseConfirmation(tester, 'Buang isian');
        if (destination == 'Home') {
          _expectHome(tester);
          expect(_navigator(tester).canPop(), isFalse);
        } else {
          expect(find.byType(ProjectFormPage), findsOneWidget);
          expect(find.byType(CertificationFormPage), findsNothing);
          expect(find.text('Tinggalkan formulir?'), findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'Back menutup Drawer dan memilih halaman aktif tidak meminta konfirmasi',
    (tester) async {
      await _openCertification(tester);
      await _enter(tester, 'certification-title', 'Draf penting');
      final originalRoute = ModalRoute.of(
        tester.element(find.byType(CertificationFormPage)),
      );
      await _openDrawer(tester);
      await _back(tester);
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      expect(find.text('Tinggalkan formulir?'), findsNothing);
      expect(find.byType(CertificationFormPage), findsOneWidget);

      await _chooseDrawer(tester, 'Add Certification');
      expect(find.text('Tinggalkan formulir?'), findsNothing);
      expect(
        ModalRoute.of(tester.element(find.byType(CertificationFormPage))),
        same(originalRoute),
      );
      expect(_value(tester, 'certification-title'), 'Draf penting');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Back yang disetujui dari satu-satunya rute formulir menuju Home',
    (tester) async {
      await tester.pumpWidget(portfolioTestApp(token: 'test-session'));
      await _chooseDrawer(tester, 'Add Certification');
      expect(_navigator(tester).canPop(), isFalse);
      await _enter(tester, 'certification-title', 'Draf penting');
      await _back(tester);
      await _chooseConfirmation(tester, 'Buang isian');
      _expectHome(tester);
      expect(_navigator(tester).canPop(), isFalse);
    },
  );

  testWidgets(
    'Permintaan Back bersamaan tidak menumpuk dialog dan menutup dialog berarti batal',
    (tester) async {
      await _openCertification(tester);
      await _enter(tester, 'certification-title', 'Draf penting');
      final navigator = _navigator(tester);
      await Future.wait([navigator.maybePop(), navigator.maybePop()]);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Tinggalkan formulir?'), findsOneWidget);

      // Back pada dialog membatalkan konfirmasi, bukan meninggalkan halaman.
      await _back(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(_value(tester, 'certification-title'), 'Draf penting');
      await _back(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await _chooseConfirmation(tester, 'Lanjut mengisi');
      expect(tester.takeException(), isNull);
    },
  );
}
