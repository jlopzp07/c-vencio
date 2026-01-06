import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:c_vencio/core/theme/app_theme.dart';
import 'package:c_vencio/core/theme/design_tokens.dart';

/// Botón con efecto glassmorphism
/// Sigue el diseño MonAI con animaciones suaves
class GlassButton extends StatefulWidget {
  /// Texto del botón
  final String text;

  /// Callback cuando se presiona el botón
  final VoidCallback onPressed;

  /// Icono opcional (a la izquierda del texto)
  final IconData? icon;

  /// Tema oscuro
  final bool isDark;

  /// Color de acento (por defecto: primary)
  final Color? accentColor;

  /// Si el botón es primario (filled) o secundario (outline)
  final bool isPrimary;

  /// Tamaño del botón (small, medium, large)
  final GlassButtonSize size;

  /// Si el botón está deshabilitado
  final bool isDisabled;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isDark,
    this.icon,
    this.accentColor,
    this.isPrimary = true,
    this.size = GlassButtonSize.medium,
    this.isDisabled = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = widget.accentColor ?? AppTheme.primary;
    final padding = _getPaddingForSize();
    final fontSize = _getFontSizeForSize();
    final iconSize = _getIconSizeForSize();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.isDisabled ? DesignTokens.disabledOpacity : 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: DesignTokens.blurSoft,
                    sigmaY: DesignTokens.blurSoft,
                  ),
                  child: AnimatedContainer(
                    duration: DesignTokens.durationNormal,
                    padding: padding,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(effectiveAccentColor),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMedium,
                      ),
                      border: Border.all(
                        color: _getBorderColor(effectiveAccentColor),
                        width: 1.5,
                      ),
                      boxShadow: widget.isPrimary && !widget.isDisabled
                          ? [
                              BoxShadow(
                                color: effectiveAccentColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: iconSize,
                            color: _getTextColor(effectiveAccentColor),
                          ),
                          SizedBox(width: DesignTokens.spaceS),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(effectiveAccentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _getPaddingForSize() {
    switch (widget.size) {
      case GlassButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceM,
          vertical: DesignTokens.spaceS,
        );
      case GlassButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceL,
          vertical: DesignTokens.spaceM,
        );
      case GlassButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceXL,
          vertical: DesignTokens.spaceL,
        );
    }
  }

  double _getFontSizeForSize() {
    switch (widget.size) {
      case GlassButtonSize.small:
        return 12;
      case GlassButtonSize.medium:
        return 14;
      case GlassButtonSize.large:
        return 16;
    }
  }

  double _getIconSizeForSize() {
    switch (widget.size) {
      case GlassButtonSize.small:
        return 16;
      case GlassButtonSize.medium:
        return 20;
      case GlassButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(Color accentColor) {
    if (widget.isPrimary) {
      return _isPressed ? accentColor.withValues(alpha: 0.9) : accentColor;
    } else {
      return _isPressed
          ? DesignTokens.glassBackgroundFor(
              widget.isDark,
            ).withValues(alpha: 0.2)
          : DesignTokens.glassBackgroundFor(widget.isDark);
    }
  }

  Color _getBorderColor(Color accentColor) {
    if (widget.isPrimary) {
      return accentColor;
    } else {
      return _isPressed ? accentColor : accentColor.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(Color accentColor) {
    if (widget.isPrimary) {
      return Colors.white;
    } else {
      return accentColor;
    }
  }
}

/// Tamaños disponibles para GlassButton
enum GlassButtonSize { small, medium, large }
