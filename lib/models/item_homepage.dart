import 'package:material_ui/material_ui.dart';

/// Data aksi dipisahkan dari tampilannya agar daftar menu mudah diperluas.
class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.color, {this.destination});

  final String name;
  final IconData icon;
  // Warna ditentukan oleh data aksi, tanpa percabangan nama di ItemCard.
  final Color color;
  // Hanya aksi yang membuka halaman memiliki tujuan navigasi.
  final ({String routeName, Widget page})? destination;
}
