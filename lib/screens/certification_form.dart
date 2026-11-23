import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/certification_preview.dart';

class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key});

  static const routeName = '/certification';

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _year = TextEditingController();
  late final _textChanges = Listenable.merge([_title, _description, _year]);
  bool _isHighlight = false;

  Future<void> _submit() async {
    // Semua validator dijalankan sebelum ringkasan dibuat.
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final values = {
      'Judul': _title.text.trim(),
      'Deskripsi': _description.text.trim(),
      'Tahun': int.parse(_year.text.trim()).toString(),
      'Unggulan': _isHighlight ? 'Ya' : 'Tidak',
    };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Sertifikasi'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: values.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('${entry.key}: ${entry.value}'),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Tambah Sertifikasi',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Lengkapi informasi sertifikasi dan pilih apakah ingin menjadikannya unggulan.',
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _title,
                      builder: (context, value, child) => TextFormField(
                        key: const Key('certification-title'),
                        controller: _title,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Judul Sertifikasi',
                          helperText:
                              'Maksimal ${FormValidators.certificationTitleLimit} karakter.',
                          errorMaxLines: 3,
                          // Ikuti hitungan Unicode setelah trim pada validator.
                          // Input tidak dipotong agar kesalahan tetap bisa dijelaskan.
                          counterText:
                              '${value.text.trim().runes.length}/${FormValidators.certificationTitleLimit}',
                          counterStyle:
                              value.text.trim().runes.length >
                                  FormValidators.certificationTitleLimit
                              ? TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                )
                              : null,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => FormValidators.requiredText(
                          value,
                          'Judul sertifikasi',
                          maxLength: FormValidators.certificationTitleLimit,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('certification-description'),
                      controller: _description,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Deskripsi Sertifikasi',
                        errorMaxLines: 3,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) => FormValidators.requiredText(
                        value,
                        'Deskripsi sertifikasi',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('certification-year'),
                      controller: _year,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tahun Sertifikasi',
                        hintText: 'Contoh: 2026',
                        errorMaxLines: 3,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: FormValidators.certificationYear,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      key: const Key('certification-highlight'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sertifikasi unggulan'),
                      subtitle: const Text(
                        'Tandai sertifikasi yang ingin ditonjolkan.',
                      ),
                      value: _isHighlight,
                      onChanged: (value) =>
                          setState(() => _isHighlight = value),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan'),
                    ),
                    const SizedBox(height: 24),
                    ListenableBuilder(
                      listenable: _textChanges,
                      builder: (context, child) => CertificationPreview(
                        title: _title.text,
                        description: _description.text,
                        year: _year.text,
                        isHighlight: _isHighlight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
