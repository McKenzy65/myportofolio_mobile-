import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Proyek'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(project.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(project.techStack, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(project.description),
            const SizedBox(height: 16),
            SelectableText(project.projectUrl),
            if (project.projectImageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Image.network(
                project.projectImageUrl,
                fit: BoxFit.contain,
                semanticLabel: 'Gambar proyek ${project.title}',
                errorBuilder: (_, _, _) =>
                    const Text('Gambar proyek belum bisa dimuat.'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
