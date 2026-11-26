import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/certification_preview.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/unsaved_form_guard.dart';
import 'package:provider/provider.dart';

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
  bool _hasDraft = false;
  bool _drawerOpen = false;
  bool _validationAttempted = false;
  bool _submitting = false;
  bool _saved = false;

  bool get _readOnly => _submitting || _saved;

  bool get _containsDraft =>
      _title.text.isNotEmpty ||
      _description.text.isNotEmpty ||
      _year.text.isNotEmpty ||
      _isHighlight;

  @override
  void initState() {
    super.initState();
    _textChanges.addListener(_updateDraftState);
  }

  void _updateDraftState() {
    // Rebuild penjaga navigasi hanya ketika status kosong/terisi berubah.
    // Perubahan teks lainnya diperbarui oleh listener pratinjau/counter saja.
    if (!_saved && _hasDraft != _containsDraft) {
      setState(() => _hasDraft = _containsDraft);
    }
  }

  Future<void> _submit() async {
    if (_readOnly) return;
    if (!_validationAttempted) setState(() => _validationAttempted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final api = context.read<ApiClient>();
    final session = context.read<AuthState>();
    final draft = Certification(
      title: _title.text.trim(),
      description: _description.text.trim(),
      year: int.parse(_year.text.trim()),
      isHighlight: _isHighlight,
    );
    String? sentToken;
    setState(() => _submitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      sentToken = session.token;
      if (sentToken == null) return;
      final saved = await api.createCertification(draft, token: sentToken);
      if (!mounted) return;
      setState(() {
        _saved = true;
        _hasDraft = false;
        _isHighlight = saved.isHighlight;
      });
      // Django membersihkan spasi dan tag HTML sebelum menyimpan.
      _title.text = saved.title;
      _description.text = saved.description;
      _year.text = saved.year.toString();
      final viewList = await _showReceipt(saved);
      if (mounted && viewList == true) {
        Navigator.pushReplacementNamed(
          context,
          CertificationListScreen.routeName,
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 && sentToken != null) {
        session.invalidateToken(sentToken);
        _message('Sesi berakhir. Silakan login kembali.');
        if (await ensureLoggedIn(context) && mounted) {
          _message('Sesi aktif kembali. Tekan Simpan untuk mengirim draf.');
        }
      } else {
        _message('${error.message} (HTTP ${error.statusCode})');
      }
    } catch (_) {
      if (mounted) {
        _message(
          'Penyimpanan belum terkonfirmasi. Periksa koneksi dan daftar sertifikasi.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  void _startNew() {
    _formKey.currentState!.reset();
    _title.clear();
    _description.clear();
    _year.clear();
    setState(() {
      _saved = false;
      _hasDraft = false;
      _isHighlight = false;
      _validationAttempted = false;
    });
  }

  Future<bool?> _showReceipt(Certification saved) {
    final values = {
      'Judul': saved.title,
      'Deskripsi': saved.description,
      'Tahun': saved.year.toString(),
      'Unggulan': saved.isHighlight ? 'Ya' : 'Tidak',
    };
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Sertifikasi'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sertifikasi berhasil disimpan.'),
            const SizedBox(height: 12),
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lihat daftar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textChanges.removeListener(_updateDraftState);
    _title.dispose();
    _description.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedFormGuard(
      hasChanges: _hasDraft,
      navigationLocked: _submitting,
      drawerOpen: _drawerOpen,
      builder: (context, confirmLeave) => Scaffold(
        onDrawerChanged: (open) => setState(() => _drawerOpen = open),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            'Tambah Sertifikasi',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        drawer: _submitting ? null : LeftDrawer(onBeforeNavigate: confirmLeave),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _validationAttempted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _saved ? 'Sertifikasi tersimpan.' : 'Lengkapi informasi sertifikasi dan pilih apakah ingin menjadikannya unggulan.',
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _title,
                        builder: (context, value, child) => TextFormField(
                          key: const Key('certification-title'),
                          controller: _title,
                          readOnly: _readOnly,
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
                        readOnly: _readOnly,
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
                        readOnly: _readOnly,
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
                        onChanged: _readOnly
                            ? null
                            : (value) => setState(() {
                                _isHighlight = value;
                                _hasDraft = _containsDraft;
                              }),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _submitting
                            ? null
                            : _saved
                            ? _startNew
                            : _submit,
                        icon: Icon(_saved ? Icons.add : Icons.save_outlined),
                        label: Text(
                          _submitting
                              ? 'Menyimpan...'
                              : _saved
                              ? 'Tambah lagi'
                              : 'Simpan',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListenableBuilder(
                        listenable: _textChanges,
                        builder: (context, child) => CertificationPreview(
                          title: _title.text,
                          description: _description.text,
                          year: _year.text,
                          isHighlight: _isHighlight,
                          saved: _saved,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
