import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Finder _field(String key) => find.byKey(ValueKey(key));

Future<void> _openProject(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  await tester.ensureVisible(_field(key));
  await tester.pumpAndSettle();
  await tester.enterText(_field(key), value);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

String _value(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(of: _field(key), matching: find.byType(EditableText)),
    )
    .controller
    .text;

void main() {
  testWidgets('Nama dan deskripsi kosong atau hanya spasi ditolak', (
    tester,
  ) async {
    await _openProject(tester);
    for (final value in ['', '   ']) {
      await _enter(tester, 'project-name', value);
      await _enter(tester, 'project-description', value);
      await _save(tester);
      expect(
        tester.state<FormFieldState<String>>(_field('project-name')).hasError,
        isTrue,
      );
      expect(
        tester
            .state<FormFieldState<String>>(_field('project-description'))
            .hasError,
        isTrue,
      );
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Teknologi dan tautan opsional; kategori awal Web Development', (
    tester,
  ) async {
    await _openProject(tester);
    await _enter(tester, 'project-name', 'Portofolio');
    await _enter(tester, 'project-description', 'Proyek pribadi');
    await _save(tester);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Teknologi: -'), findsOneWidget);
    expect(find.text('Tautan: -'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
  });

  testWidgets(
    'Dialog memuat lima nilai dan OK mereset semua input serta kategori',
    (tester) async {
      await _openProject(tester);
      await _enter(tester, 'project-name', '  Portofolio Umar  ');
      await _enter(
        tester,
        'project-description',
        '  Situs portofolio pribadi  ',
      );
      await tester.ensureVisible(_field('project-category'));
      await tester.tap(_field('project-category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();
      await _enter(tester, 'project-technologies', 'Dart, Flutter');
      await _enter(tester, 'project-link', 'https://example.com/portfolio');
      await _save(tester);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      for (final value in [
        'Nama Proyek: Portofolio Umar',
        'Deskripsi: Situs portofolio pribadi',
        'Kategori: Other',
        'Teknologi: Dart, Flutter',
        'Tautan: https://example.com/portfolio',
      ]) {
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final key in [
        'project-name',
        'project-description',
        'project-technologies',
        'project-link',
      ]) {
        expect(_value(tester, key), isEmpty);
      }
      expect(
        tester.state<FormFieldState<String>>(_field('project-category')).value,
        'Web Development',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('Save terjangkau pada ponsel dengan keyboard dan font $scale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _openProject(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      await _enter(tester, 'project-name', 'Portofolio');
      await _enter(tester, 'project-description', 'Proyek pribadi');
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Save').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Save'));
      // _submit menghilangkan fokus; simulasikan keyboard yang menutup.
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
}
