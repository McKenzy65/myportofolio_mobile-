import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  testWidgets(
    'Drawer berpindah halaman tanpa menumpuk rute atau mereset halaman aktif',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      Future<void> select(String label) async {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ListTile, label));
        await tester.pumpAndSettle();
      }

      await select('Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(navigator.canPop(), isFalse);
      await tester.enterText(find.byKey(const Key('project-name')), 'Draf PBP');
      await select('Add Project');
      expect(find.text('Draf PBP'), findsOneWidget);
      await select('Home');
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
      expect(navigator.canPop(), isFalse);
    },
  );
}
