import 'package:flutter/material.dart';

/// Data aksi dipisahkan dari tampilannya agar daftar menu mudah diperluas.
class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  // Warna ditentukan oleh data aksi, tanpa percabangan nama di ItemCard.
  final Color color;
}
