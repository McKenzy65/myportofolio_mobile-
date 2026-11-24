import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

/// State tema hidup di root; halaman menu tetap StatelessWidget sesuai Tugas 7.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.apiClient, this.initialToken});

  final ApiClient? apiClient;
  final String? initialToken;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() => setState(() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      if (widget.apiClient case final client?)
        Provider<ApiClient>.value(value: client)
      else
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, client) => client.close(),
        ),
      ChangeNotifierProvider(
        create: (context) => AuthState(
          context.read<ApiClient>(),
          initialToken: widget.initialToken,
        ),
      ),
    ],
    child: MaterialApp(
      title: 'MyPortfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: MyHomePage(onToggleTheme: _toggleTheme),
      routes: {
        ProjectFormPage.routeName: (_) => const ProjectFormEntry(),
        ProjectListScreen.routeName: (_) => const ProjectListScreen(),
        CertificationFormPage.routeName: (_) => const CertificationFormPage(),
      },
    ),
  );
}
