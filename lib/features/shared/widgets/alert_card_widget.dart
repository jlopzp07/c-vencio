import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';

/// Widget reutilizable para mostrar tarjetas de alertas
/// (SOAT, Tecnicomecánica, etc.) con estado vigente/vencido.
class AlertCardWidget extends StatelessWidget {
  final String title;
  final dynamic data;
  final IconData icon;
  final bool isDark;

  const AlertCardWidget({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = false;
    String status = 'Vigente';
    Color accentColor = AppTheme.accentGreen;

    if (data is Map) {
      isActive = data['vigente'] == true || data['estado'] == 'VIGENTE';
      if (!isActive) {
        status = 'Vencido';
        accentColor = AppTheme.accentRed;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black54,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
