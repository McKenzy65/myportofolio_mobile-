import 'package:flutter/material.dart';

/// Kartu identitas yang mengikuti tema aplikasi dan pembesaran teks perangkat.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.trailing,
  });

  final String title;
  final String content;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
