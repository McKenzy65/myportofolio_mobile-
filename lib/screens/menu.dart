import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/models/portfolio_profile.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/copy_npm_button.dart';

/// Menu tetap stateless: identitas dan daftar aksi adalah data immutable.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  static const items = [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder,
      Color(0xFF1D4ED8),
      destination: (
        routeName: ProjectListScreen.routeName,
        page: ProjectListScreen(),
      ),
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle,
      Color(0xFF166534),
      destination: (
        routeName: ProjectFormPage.routeName,
        page: ProjectFormPage(),
      ),
    ),
    ItemHomepage(
      'Tambah Sertifikasi',
      Icons.workspace_premium,
      Color(0xFF6B21A8),
      destination: (
        routeName: CertificationFormPage.routeName,
        page: CertificationFormPage(),
      ),
    ),
    ItemHomepage('Logout', Icons.logout, Color(0xFFB91C1C)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('MyPortfolio'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: theme.brightness == Brightness.light
                ? 'Aktifkan mode gelap'
                : 'Aktifkan mode terang',
            onPressed: onToggleTheme,
            icon: Icon(
              theme.brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final scale =
                          MediaQuery.textScalerOf(context).scale(14) / 14;
                      final columns =
                          constraints.maxWidth >= 600 && scale <= 1.5 ? 3 : 1;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 12) / columns;
                      // Wrap membiarkan tinggi kartu mengikuti isi tanpa batas tinggi.
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: width,
                            child: const InfoCard(
                              title: 'NPM',
                              content: PortfolioProfile.npm,
                              icon: Icons.badge_outlined,
                              trailing: CopyNpmButton(),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: const InfoCard(
                              title: 'Name',
                              content: PortfolioProfile.name,
                              icon: Icons.person_outline,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: const InfoCard(
                              title: 'Class',
                              content: PortfolioProfile.className,
                              icon: Icons.school_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Selamat datang di MyPortfolio Mobile!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ruang untuk proyek dan perjalanan belajar saya.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final scale =
                          MediaQuery.textScalerOf(context).scale(14) / 14;
                      final columns =
                          constraints.maxWidth >= 880 && scale <= 1.25
                          ? 4
                          : constraints.maxWidth >= 600 && scale <= 1.5
                          ? 2
                          : 1;
                      return GridView.count(
                        crossAxisCount: columns,
                        mainAxisExtent: 144 * scale,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        children: items.map((item) => ItemCard(item)).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
