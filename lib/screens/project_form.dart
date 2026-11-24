import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Handles a direct link to /project as well as named drawer navigation.
class ProjectFormEntry extends StatefulWidget {
  const ProjectFormEntry({super.key});

  @override
  State<ProjectFormEntry> createState() => _ProjectFormEntryState();
}

class _ProjectFormEntryState extends State<ProjectFormEntry> {
  late final bool _alreadyAuthenticated = context.read<AuthState>().isLoggedIn;
  bool _loggedInHere = false;
  @override
  Widget build(BuildContext context) => _alreadyAuthenticated || _loggedInHere
      ? const ProjectFormPage()
      : LoginScreen(onLoggedIn: () => setState(() => _loggedInHere = true));
}

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});
  static const routeName = '/project';

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _technologies = TextEditingController();
  final _link = TextEditingController();
  final _image = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _technologies.dispose();
    _link.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;
      final created = await api.createProject(
        Project(
          title: _name.text.trim(),
          description: _description.text.trim(),
          techStack: _technologies.text.trim(),
          projectUrl: _link.text.trim(),
          projectImageUrl: _image.text.trim(),
        ),
        token: token,
      );
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      final reset = await _confirm(created);
      if (mounted && reset == true) {
        _formKey.currentState!.reset();
        for (final field in [
          _name,
          _description,
          _technologies,
          _link,
          _image,
        ]) {
          field.clear();
        }
      }
    } on ApiException catch (error) {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (error.statusCode == 401) {
        try {
          await auth.logout();
        } catch (_) {
          // AuthState juga menghapus token lokal ketika server menolak token lama.
        }
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        _message('Sesi berakhir. Silakan login kembali.');
        if (await ensureLoggedIn(context) && mounted) {
          _message('Sesi aktif kembali. Tekan Save untuk mengirim proyek.');
        }
      } else {
        _message('${error.message} (HTTP ${error.statusCode})');
      }
    } catch (_) {
      if (mounted) {
        _message(
          'Proyek belum dapat disimpan. Periksa koneksimu dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<bool?> _confirm(Project project) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Proyek berhasil ditambahkan!'),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nama Proyek: ${project.title}'),
          Text('Deskripsi: ${project.description}'),
          Text('Teknologi: ${project.techStack}'),
          Text('URL Proyek: ${project.projectUrl}'),
          Text(
            'URL Gambar: ${project.projectImageUrl.isEmpty ? '-' : project.projectImageUrl}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Add Project Form', overflow: TextOverflow.ellipsis),
      ),
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
                    _field(
                      'project-name',
                      'Nama Proyek',
                      _name,
                      validator: (v) => FormValidators.requiredText(
                        v,
                        'Nama proyek',
                        maxLength: 255,
                      ),
                    ),
                    _field(
                      'project-description',
                      'Deskripsi Proyek',
                      _description,
                      multiline: true,
                      validator: (v) =>
                          FormValidators.requiredText(v, 'Deskripsi proyek'),
                    ),
                    _field(
                      'project-technologies',
                      'Teknologi',
                      _technologies,
                      validator: (v) => FormValidators.requiredText(
                        v,
                        'Teknologi',
                        maxLength: 255,
                      ),
                    ),
                    _field(
                      'project-link',
                      'URL Proyek',
                      _link,
                      isUrl: true,
                      validator: FormValidators.projectUrl,
                    ),
                    _field(
                      'project-image',
                      'URL Gambar Proyek (opsional)',
                      _image,
                      isUrl: true,
                      validator: (v) =>
                          FormValidators.projectUrl(v, optional: true),
                    ),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_submitting ? 'Menyimpan…' : 'Save'),
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

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    required FormFieldValidator<String> validator,
    bool multiline = false,
    bool isUrl = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey(key),
      controller: controller,
      readOnly: _submitting,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorMaxLines: 3,
      ),
      minLines: multiline ? 3 : 1,
      maxLines: multiline ? 5 : 1,
      keyboardType: multiline
          ? TextInputType.multiline
          : isUrl
          ? TextInputType.url
          : TextInputType.text,
      textInputAction: multiline
          ? TextInputAction.newline
          : TextInputAction.next,
      validator: validator,
    ),
  );
}
