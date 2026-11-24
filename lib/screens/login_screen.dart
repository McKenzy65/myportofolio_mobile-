import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoggedIn});
  final VoidCallback? onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await context.read<AuthState>().login(_username.trim(), _password);
      if (!mounted) return;
      if (widget.onLoggedIn != null) {
        widget.onLoggedIn!();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        ApiException(statusCode: 400 || 401) =>
          'Periksa username dan password (HTTP ${error.statusCode}).',
        ApiException() => 'Login gagal (HTTP ${error.statusCode}).',
        _ => 'Server belum bisa dihubungi. Coba lagi.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => _username = value,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Username wajib diisi.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            onChanged: (value) => _password = value,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Password wajib diisi.'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
