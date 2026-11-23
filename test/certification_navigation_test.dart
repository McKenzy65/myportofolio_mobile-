import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> _chooseDrawer(WidgetTester tester, String destination) async {
  await _openDrawer(tester);
  await tester.tap(find.text(destination));
  await tester.pumpAndSettle();
}

Future<void> _openCertificationCard(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
}

NavigatorState _navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

void main() {
  testWidgets('Kartu sertifikasi membuka form dan Back kembali ke Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openCertificationCard(tester);
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(_navigator(tester).canPop(), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CertificationFormPage), findsNothing);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(_navigator(tester).canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Drawer menandai halaman aktif dan tetap menghubungkan kedua form',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await _chooseDrawer(tester, 'Add Certification');
      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(_navigator(tester).canPop(), isFalse);
      final certificationRoute = ModalRoute.of(
        tester.element(find.byType(CertificationFormPage)),
      );
      await _openDrawer(tester);
      expect(
        tester
            .widget<ListTile>(
              find.widgetWithText(ListTile, 'Add Certification'),
            )
            .selected,
        isTrue,
      );
      await tester.tap(find.text('Add Certification'));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      expect(
        ModalRoute.of(tester.element(find.byType(CertificationFormPage))),
        same(certificationRoute),
      );
      expect(_navigator(tester).canPop(), isFalse);
      await _chooseDrawer(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(CertificationFormPage), findsNothing);
      await _chooseDrawer(tester, 'Home');
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(_navigator(tester).canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home dari form yang dibuka lewat kartu membersihkan tumpukan rute',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await _openCertificationCard(tester);
      expect(_navigator(tester).canPop(), isTrue);
      await _chooseDrawer(tester, 'Home');
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
      expect(find.byType(CertificationFormPage), findsNothing);
      expect(_navigator(tester).canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
