import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';

void main() => runApp(const MyApp());

/// State tema hidup di root; halaman menu tetap StatelessWidget sesuai Tugas 7.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() => setState(() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MyPortfolio',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: _mode,
    home: MyHomePage(onToggleTheme: _toggleTheme),
    routes: {
      ProjectFormPage.routeName: (_) => const ProjectFormPage(),
      CertificationFormPage.routeName: (_) => const CertificationFormPage(),
    },
  );
}
