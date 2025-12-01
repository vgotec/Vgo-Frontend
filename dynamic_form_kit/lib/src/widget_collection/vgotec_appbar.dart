import 'package:flutter/material.dart';

class VgotecAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;
  final bool centerTitle;
  final bool showMenuIcon;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;
  final TextStyle? titleTextStyle;

  const VgotecAppBar({
    super.key,
    this.title = 'Default Title',
    this.backgroundColor = const Color(0xFF06179B),
    this.titleColor = Colors.white,
    this.elevation = 0,
    this.centerTitle = false,
    this.showMenuIcon = true,
    this.onMenuPressed,
    this.actions,
    this.titleTextStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      leading: showMenuIcon
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
            )
          : null,
      title: Text(
        title,
        style: titleTextStyle ??
            TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
      ),
      actions: actions,
    );
  }
}
