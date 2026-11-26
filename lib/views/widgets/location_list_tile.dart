import 'package:flutter/material.dart';

import '../../models/location.dart';

/// Item baris kota untuk hasil pencarian, daftar favorit, maupun riwayat pencarian.
class LocationListTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;

  const LocationListTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    this.leadingIcon = Icons.location_city_rounded,
    this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Icon(leadingIcon, color: colorScheme.primary),
        title: Text(
          location.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: location.subtitle.isNotEmpty
            ? Text(
                location.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onToggleFavorite != null)
              IconButton(
                tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? Colors.amber : colorScheme.onSurfaceVariant,
                ),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Hapus',
                onPressed: onDelete,
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
