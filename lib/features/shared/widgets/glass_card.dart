import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';

/// Widget reutilizable con efecto glassmorphism
/// Implementa el diseño Liquid Glass característico de MonAI
class GlassCard extends StatelessWidget {
  /// Contenido del card
  final Widget child;

  /// Radio de los bordes (por defecto: radiusLarge)
  final double borderRadius;

  /// Intensidad del blur (por defecto: blurMedium)
  final double blur;

  /// Color de fondo personalizado (opcional)
  final Color? backgroundColor;

  /// Color del borde personalizado (opcional)
  final Color? borderColor;

  /// Ancho del borde (por defecto: 1.0)
  final double borderWidth;

  /// Padding interno (por defecto: 20px)
  final EdgeInsetsGeometry? padding;

  /// Si debe mostrar sombra (por defecto: true)
  final bool showShadow;

  /// Tema oscuro (para determinar colores automáticos)
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = DesignTokens.radiusLarge,
    this.blur = DesignTokens.blurMedium,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(DesignTokens.spaceM),
          decoration: BoxDecoration(
            color: backgroundColor ?? DesignTokens.glassBackgroundFor(isDark),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? DesignTokens.glassStrokeFor(isDark),
              width: borderWidth,
            ),
            boxShadow: showShadow ? DesignTokens.shadowSoftFor(isDark) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Variante de GlassCard sin blur para mejor performance
/// Útil para listas largas o grids con muchos elementos
class GlassCardLite extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final bool isDark;

  const GlassCardLite({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = DesignTokens.radiusLarge,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignTokens.glassBackgroundFor(isDark),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? DesignTokens.glassStrokeFor(isDark),
          width: borderWidth,
        ),
        boxShadow: showShadow ? DesignTokens.shadowSoftFor(isDark) : null,
      ),
      child: child,
    );
  }
}
