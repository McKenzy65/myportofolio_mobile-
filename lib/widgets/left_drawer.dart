import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, this.onBeforeNavigate});

  final Future<bool> Function()? onBeforeNavigate;

  Future<void> _open(BuildContext context, String destination) async {
    final navigator = Navigator.of(context);
    final owner = ModalRoute.of(context);
    Scaffold.of(context).closeDrawer();
    if (owner?.settings.name == destination) return;
    final confirm = onBeforeNavigate;
    if (confirm != null && !await confirm()) return;
    // Drawer dapat tertutup selama dialog terbuka. Periksa rute pemiliknya.
    if (!navigator.mounted || owner?.isCurrent != true) return;
    if (destination == Navigator.defaultRouteName) {
      // Home becomes the root even if the form was opened over another Home.
      navigator.pushNamedAndRemoveUntil(destination, (_) => false);
    } else {
      navigator.pushReplacementNamed(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = ModalRoute.of(context)?.settings.name;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ColoredBox(
            color: colors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Portfolio',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: colors.onPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proyek dan pengalaman saya',
                      style: TextStyle(color: colors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            selected: current == Navigator.defaultRouteName,
            onTap: () => _open(context, Navigator.defaultRouteName),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Projects'),
            selected: current == ProjectListScreen.routeName,
            onTap: () => _open(context, ProjectListScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            selected: current == ProjectFormPage.routeName,
            onTap: () => _open(context, ProjectFormPage.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Add Certification'),
            selected: current == CertificationFormPage.routeName,
            onTap: () => _open(context, CertificationFormPage.routeName),
          ),
        ],
      ),
    );
  }
}
