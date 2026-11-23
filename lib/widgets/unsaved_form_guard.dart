import 'package:material_ui/material_ui.dart';

/// Menyatukan konfirmasi Back dan navigasi drawer agar keputusan tidak berbeda.
/// Penggantian rute oleh drawer tidak melewati PopScope; panggil confirmLeave
/// dari builder sebelum melakukan navigasi tersebut.
class UnsavedFormGuard extends StatefulWidget {
  const UnsavedFormGuard({
    super.key,
    required this.hasChanges,
    required this.drawerOpen,
    required this.builder,
  });

  final bool hasChanges;
  final bool drawerOpen;
  final Widget Function(
    BuildContext context,
    Future<bool> Function() confirmLeave,
  )
  builder;

  @override
  State<UnsavedFormGuard> createState() => _UnsavedFormGuardState();
}

class _UnsavedFormGuardState extends State<UnsavedFormGuard> {
  bool _confirming = false;

  Future<bool> _confirmLeave() async {
    // Abaikan permintaan kedua agar ketukan cepat tidak menumpuk dialog/rute.
    if (_confirming) return false;
    if (!widget.hasChanges) return true;
    _confirming = true;
    try {
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Tinggalkan formulir?'),
          scrollable: true,
          content: const Text(
            'Isian sertifikasi belum disimpan. Ringkasan hanya menampilkan '
            'data. Jika keluar, isian akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Lanjut mengisi'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Buang isian'),
            ),
          ],
        ),
      );
      return mounted && discard == true;
    } finally {
      _confirming = false;
    }
  }

  Future<void> _onBack(bool didPop, Object? result) async {
    // Back ketika drawer terbuka hanya menutup drawer, bukan membuang form.
    if (didPop || widget.drawerOpen) return;
    if (!await _confirmLeave() || !mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      // pop eksplisit hanya dilakukan setelah persetujuan pengguna.
      navigator.pop(result);
    } else {
      // Form dari pushReplacementNamed bisa menjadi satu-satunya rute.
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !widget.hasChanges || widget.drawerOpen,
    onPopInvokedWithResult: _onBack,
    child: widget.builder(context, _confirmLeave),
  );
}
