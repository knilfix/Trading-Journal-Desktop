import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix;
  final IconData? icon;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final String? Function(String?)? validator;
  final VoidCallback? onIconTap; // New callback for icon tap

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefix,
    this.icon,
    this.iconColor,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.validator,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        hintText: hintText,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF5F7FA)
            : Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        prefixIcon: icon != null
            ? InkWell(
                onTap: onIconTap, // Make icon clickable
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).iconTheme.color,
                ),
              )
            : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
