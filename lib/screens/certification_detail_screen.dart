import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

class CertificationDetailScreen extends StatefulWidget {
  const CertificationDetailScreen({super.key, required this.id});

  final int id;

  @override
  State<CertificationDetailScreen> createState() =>
      _CertificationDetailScreenState();
}

class _CertificationDetailScreenState extends State<CertificationDetailScreen> {
  late Future<Certification> _entry;

  @override
  void initState() {
    super.initState();
    _entry = context.read<ApiClient>().getCertification(widget.id);
  }

  void _reload() {
    setState(() {
      _entry = context.read<ApiClient>().getCertification(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sertifikasi'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: FutureBuilder<Certification>(
          future: _entry,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final missing =
                  snapshot.error is ApiException &&
                  (snapshot.error as ApiException).statusCode == 404;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      missing
                          ? 'Sertifikasi ini sudah tidak tersedia.'
                          : 'Detail sertifikasi belum bisa dimuat.',
                    ),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            final entry = snapshot.requireData;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(entry.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(entry.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Text('Tahun: ${entry.year}'),
                    const SizedBox(height: 8),
                    Text('Unggulan: ${entry.isHighlight ? 'Ya' : 'Tidak'}'),
                    const SizedBox(height: 8),
                    Text('Jumlah bintang: ${entry.starCount}'),
                    const SizedBox(height: 8),
                    Text(
                      'Ditandai pada akses publik: ${entry.isStarred ? 'Ya' : 'Tidak'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pemberi bintang: ${entry.starredByNames.isEmpty ? 'Belum ada' : entry.starredByNames}',
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      'ID: ${entry.id}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
