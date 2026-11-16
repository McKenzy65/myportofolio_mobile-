import 'package:flutter/material.dart';

/// Data aksi dipisahkan dari tampilannya agar daftar menu mudah diperluas.
class ItemHomepage {
  const ItemHomepage(this.name, this.icon);

  final String name;
  final IconData icon;
}
