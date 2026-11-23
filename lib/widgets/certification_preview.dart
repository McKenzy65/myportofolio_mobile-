import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';

/// Kartu tampilan saja: sumber data tetap controller pada formulir.
/// Pratinjau boleh menampilkan draf belum lengkap tanpa melewati validasi Simpan.
class CertificationPreview extends StatelessWidget {
  const CertificationPreview({
    super.key,
    required this.title,
    required this.description,
    required this.year,
    required this.isHighlight,
  });

  final String title;
  final String description;
  final String year;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yearLabel = year.trim().isEmpty
        ? 'Tahun belum diisi'
        : FormValidators.certificationYear(year) == null
        ? 'Tahun ${int.parse(year.trim())}'
        : 'Tahun belum valid';

    return Card(
      key: const Key('certification-preview'),
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pratinjau sertifikasi', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Text(
              title.trim().isEmpty ? 'Judul sertifikasi kamu' : title.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description.trim().isEmpty
                  ? 'Deskripsi sertifikasi akan tampil di sini.'
                  : description.trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(yearLabel),
            if (isHighlight) ...[
              const SizedBox(height: 8),
              const Chip(
                avatar: Icon(Icons.star, size: 18),
                label: Text('Unggulan'),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Pratinjau ini belum menyimpan data.'),
          ],
        ),
      ),
    );
  }
}
