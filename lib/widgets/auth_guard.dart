import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
  );
  return result == true;
}

Future<void> logoutWithFeedback(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthState>();
  if (!auth.isLoggedIn) {
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Kamu belum login.')));
    return;
  }
  var message = 'Kamu berhasil logout.';
  try {
    await auth.logout();
  } catch (_) {
    message =
        'Sesi di aplikasi sudah ditutup. Logout di server belum terkonfirmasi.';
  }
  if (messenger.mounted) {
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
