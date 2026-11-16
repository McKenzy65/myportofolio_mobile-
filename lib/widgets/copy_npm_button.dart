import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myportofolio_mobile/models/portfolio_profile.dart';

/// Menyalin sumber NPM yang sama dengan kartu, dengan umpan balik berhasil/gagal.
class CopyNpmButton extends StatelessWidget {
  const CopyNpmButton({super.key});

  Future<void> _copy(BuildContext context) async {
    var message = 'NPM berhasil disalin.';
    try {
      await Clipboard.setData(const ClipboardData(text: PortfolioProfile.npm));
    } on PlatformException {
      message = 'NPM belum berhasil disalin. Coba lagi.';
    }
    // Izin clipboard dapat selesai setelah halaman ditutup.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Salin NPM',
    onPressed: () => _copy(context),
    icon: const Icon(Icons.copy_outlined),
  );
}
