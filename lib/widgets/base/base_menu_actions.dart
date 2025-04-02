import 'package:flutter/material.dart';

/// A generic base class for menu action buttons (three dots) with consistent styling
class BaseMenuButton extends StatelessWidget {
  /// The icon to use for the button (defaults to three vertical dots)
  final IconData icon;
  
  /// The menu items to display
  final List<PopupMenuItem<String>> items;
  
  /// Callback when an item is selected
  final Function(String) onSelected;
  
  /// Constructor
  const BaseMenuButton({
    super.key,
    this.icon = Icons.more_vert,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(icon),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onSelected,
      itemBuilder: (context) => items,
    );
  }
  
  /// Helper method to create a standard menu item
  static PopupMenuItem<String> createMenuItem({
    required String value,
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(text, style: textColor != null ? TextStyle(color: textColor) : null),
        ],
      ),
    );
  }
}
