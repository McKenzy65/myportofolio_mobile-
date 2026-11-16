import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

const _actions = ['Lihat Proyek', 'Tambah Proyek', 'Logout'];

Finder _message(String text) =>
    find.descendant(of: find.byType(SnackBar), matching: find.text(text));

void _expectReadableUniqueColors(WidgetTester tester) {
  final colors = <Color>[];
  for (final action in _actions) {
    final card = find.widgetWithText(ItemCard, action);
    expect(card, findsOneWidget);
    final background = tester
        .widget<Material>(
          find.descendant(of: card, matching: find.byType(Material)).first,
        )
        .color!;
    colors.add(background);
    // Rasio kontras teks putih terhadap latar, minimum WCAG untuk teks normal.
    final contrast = 1.05 / (background.computeLuminance() + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5), reason: action);
    expect(
      tester
          .widget<Text>(find.descendant(of: card, matching: find.text(action)))
          .style
          ?.color,
      Colors.white,
    );
  }
  expect(colors.toSet(), hasLength(3));
}

void main() {
  testWidgets(
    'Menu tetap Stateless dan tiga aksi punya warna unik yang terbaca',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(tester.widget(find.byType(MyHomePage)), isA<StatelessWidget>());
      _expectReadableUniqueColors(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Mode gelap dan terang berganti tanpa menghilangkan identitas atau aksi',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(MyHomePage))).brightness;
      expect(brightness(), Brightness.light);
      await tester.tap(find.byTooltip('Aktifkan mode gelap'));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);
      for (final identity in ['2506616711', 'Umar Faiz Rahman', 'PBP F']) {
        expect(find.text(identity), findsOneWidget);
      }
      _expectReadableUniqueColors(tester);
      await tester.ensureVisible(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();
      expect(
        _message('Kamu telah menekan tombol Lihat Proyek!'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Aktifkan mode terang'));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
      _expectReadableUniqueColors(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Salin NPM mengirim identitas yang tepat ke clipboard', (
    tester,
  ) async {
    String? copiedText;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.byTooltip('Salin NPM'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Salin NPM'));
    await tester.pumpAndSettle();
    expect(copiedText, '2506616711');
    expect(_message('NPM berhasil disalin.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Clipboard yang ditolak menampilkan pesan gagal tanpa crash', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        throw PlatformException(code: 'clipboard_denied');
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.byTooltip('Salin NPM'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Salin NPM'));
    await tester.pumpAndSettle();
    expect(_message('NPM belum berhasil disalin. Coba lagi.'), findsOneWidget);
    expect(_message('NPM berhasil disalin.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ketukan aksi berurutan menampilkan pesan aksi terakhir', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (final action in _actions) {
      await tester.ensureVisible(find.text(action));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(_message('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(_message('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
    expect(_message('Kamu telah menekan tombol Tambah Proyek!'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
