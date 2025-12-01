// lib/presentation/widgets/widget_collection/vgotec_icon.dart

import 'package:flutter/material.dart';

class VgotecIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final double backgroundRadius;
  final bool showBackground;
  final String? tooltip;
  final bool isLoading;
  final VoidCallback onPressed;

  const VgotecIcon({
    Key? key,
    required this.icon,
    required this.size,
    this.iconColor,
    this.backgroundColor,
    this.backgroundRadius = 8.0,
    this.showBackground = false,
    this.tooltip,
    this.isLoading = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      borderRadius: BorderRadius.circular(backgroundRadius),
      onTap: isLoading ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? SizedBox(
                width: size,
                height: size,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: iconColor ?? Colors.black, size: size),
      ),
    );

    final decorated = showBackground
        ? Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? iconColor?.withOpacity(0.15) ?? Colors.grey.shade200,
              borderRadius: BorderRadius.circular(backgroundRadius),
            ),
            child: button,
          )
        : button;

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: decorated);
    }
    return decorated;
  }
}
