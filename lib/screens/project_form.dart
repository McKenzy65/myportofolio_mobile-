import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

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
  String _category = 'Web Development';

  static const _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _technologies.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final values = {
      'Nama Proyek': _name.text.trim(),
      'Deskripsi': _description.text.trim(),
      'Kategori': _category,
      'Teknologi': _technologies.text.trim(),
      'Tautan': _link.text.trim(),
    };
    final reset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: values.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${entry.key}: ${entry.value.isEmpty ? "-" : entry.value}',
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (reset == true && mounted) {
      _formKey.currentState!.reset();
      for (final controller in [_name, _description, _technologies, _link]) {
        controller.clear();
      }
      setState(() => _category = _categories.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    const Text('Nama dan deskripsi proyek wajib diisi.'),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('project-name'),
                      controller: _name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                        labelText: 'Nama Proyek',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          FormValidators.requiredText(value, 'Nama proyek'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('project-description'),
                      controller: _description,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                        labelText: 'Deskripsi Proyek',
                      ),
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => FormValidators.requiredText(
                        value,
                        'Deskripsi proyek',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const Key('project-category'),
                      initialValue: _categories.first,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                        labelText: 'Kategori Proyek',
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _category = value ?? _categories.first,
                      ),
                      validator: (value) => _categories.contains(value)
                          ? null
                          : 'Pilih kategori proyek.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('project-technologies'),
                      controller: _technologies,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                        labelText: 'Teknologi yang Digunakan',
                        hintText: 'Contoh: Flutter, Django, Figma',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('project-link'),
                      controller: _link,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                        labelText: 'Tautan Proyek',
                        hintText: 'URL Proyek (opsional)',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save'),
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
