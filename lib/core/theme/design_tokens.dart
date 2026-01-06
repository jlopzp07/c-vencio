import 'package:flutter/material.dart';

/// Design Tokens para el sistema de diseño de la aplicación
/// Incluye colores, espaciados, bordes, y efectos visuales
/// siguiendo los principios de MonAI con glassmorphism sutil.
class DesignTokens {
  // ═══════════════════════════════════════════════════════════════
  // COLORES BASE (mantener paleta actual)
  // ═══════════════════════════════════════════════════════════════

  /// Color de fondo principal oscuro
  static const darkBackground = Color(0xFF0A0E21);

  /// Color de fondo para cards en tema oscuro
  static const cardBackground = Color(0xFF1D1E33);

  /// Color de acento principal (rosa MonAI)
  static const primary = Color(0xFFEB1555);

  /// Color de acento verde para estados exitosos
  static const accentGreen = Color(0xFF00C853);

  /// Color de acento rojo para errores y vencimientos
  static const accentRed = Color(0xFFEB1555);

  // ═══════════════════════════════════════════════════════════════
  // GLASSMORPHISM (NUEVOS - MonAI Style)
  // ═══════════════════════════════════════════════════════════════

  /// Fondo para efecto glass (blanco semi-transparente)
  static const glassBackground = Color(0x1AFFFFFF); // 10% white

  /// Borde para efecto glass (blanco con más opacidad)
  static const glassStroke = Color(0x33FFFFFF); // 20% white

  /// Fondo glass para tema claro
  static const glassBackgroundLight = Color(0x0DFFFFFF); // 5% white

  /// Borde glass para tema claro
  static const glassStrokeLight = Color(0x1AFFFFFF); // 10% white

  // ═══════════════════════════════════════════════════════════════
  // ESPACIADOS (8pt grid system)
  // ═══════════════════════════════════════════════════════════════

  /// Espaciado extra pequeño: 4px
  static const spaceXS = 4.0;

  /// Espaciado pequeño: 8px
  static const spaceS = 8.0;

  /// Espaciado mediano: 16px
  static const spaceM = 16.0;

  /// Espaciado grande: 24px
  static const spaceL = 24.0;

  /// Espaciado extra grande: 32px
  static const spaceXL = 32.0;

  /// Espaciado extra extra grande: 48px
  static const spaceXXL = 48.0;

  // ═══════════════════════════════════════════════════════════════
  // BORDES Y RADIOS
  // ═══════════════════════════════════════════════════════════════

  /// Radio pequeño para bordes: 8px
  static const radiusSmall = 8.0;

  /// Radio mediano para bordes: 16px
  static const radiusMedium = 16.0;

  /// Radio grande para bordes: 20px
  static const radiusLarge = 20.0;

  /// Radio extra grande para bordes: 24px
  static const radiusXLarge = 24.0;

  /// Radio circular completo
  static const radiusFull = 999.0;

  // ═══════════════════════════════════════════════════════════════
  // EFECTOS VISUALES
  // ═══════════════════════════════════════════════════════════════

  /// Blur suave para glassmorphism: 10px
  static const blurSoft = 10.0;

  /// Blur mediano para glassmorphism: 20px
  static const blurMedium = 20.0;

  /// Blur fuerte para glassmorphism: 40px
  static const blurStrong = 40.0;

  /// Opacidad para overlays: 40%
  static const overlayOpacity = 0.4;

  /// Opacidad para elementos deshabilitados: 50%
  static const disabledOpacity = 0.5;

  // ═══════════════════════════════════════════════════════════════
  // DURACIONES DE ANIMACIONES
  // ═══════════════════════════════════════════════════════════════

  /// Duración muy rápida: 100ms
  static const durationFast = Duration(milliseconds: 100);

  /// Duración normal: 300ms
  static const durationNormal = Duration(milliseconds: 300);

  /// Duración lenta: 500ms
  static const durationSlow = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════
  // SOMBRAS
  // ═══════════════════════════════════════════════════════════════

  /// Sombra suave para cards en tema oscuro
  static List<BoxShadow> get shadowSoftDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Sombra suave para cards en tema claro
  static List<BoxShadow> get shadowSoftLight => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Sombra mediana para elementos elevados
  static List<BoxShadow> get shadowMediumDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  /// Sombra mediana para tema claro
  static List<BoxShadow> get shadowMediumLight => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════

  /// Obtiene el color de fondo glass según el tema
  static Color glassBackgroundFor(bool isDark) {
    return isDark ? glassBackground : glassBackgroundLight;
  }

  /// Obtiene el color de borde glass según el tema
  static Color glassStrokeFor(bool isDark) {
    return isDark ? glassStroke : glassStrokeLight;
  }

  /// Obtiene las sombras suaves según el tema
  static List<BoxShadow> shadowSoftFor(bool isDark) {
    return isDark ? shadowSoftDark : shadowSoftLight;
  }

  /// Obtiene las sombras medianas según el tema
  static List<BoxShadow> shadowMediumFor(bool isDark) {
    return isDark ? shadowMediumDark : shadowMediumLight;
  }
}
