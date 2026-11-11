import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman awal menampilkan menu portofolio', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('MyPortfolio'),
      ),
      findsOneWidget,
    );
    expect(find.text('Halo dari MyPortfolio!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
