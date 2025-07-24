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
  final VoidCallback? onIconTap;
  final bool isIconClickable;
  final String? iconTooltip;
  final bool isPnlField;
  final TextAlign textAlign;

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
    this.isIconClickable = false, // Default to false
    this.iconTooltip,
    this.isPnlField = false,
    this.textAlign = TextAlign.center,
  }) : assert(
         !isIconClickable || onIconTap != null,
         'onIconTap must be provided when isIconClickable is true',
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: textAlign,
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
        prefixIcon: icon != null ? _buildPrefixIcon(context) : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: isPnlField ? _getPnlTextStyle(context, controller.text) : null,
    );
  }

  TextStyle? _getPnlTextStyle(BuildContext context, String value) {
    final num? pnlValue = num.tryParse(value);
    if (pnlValue == null) return null;

    if (pnlValue > 0) {
      return TextStyle(color: Colors.green.shade600);
    } else if (pnlValue < 0) {
      return TextStyle(color: Colors.red.shade600);
    }
    return TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color);
  }

  Widget _buildPrefixIcon(BuildContext context) {
    final iconWidget = Icon(
      icon,
      color: iconColor ?? Theme.of(context).iconTheme.color,
      size: isIconClickable ? 22 : 20, // Slightly larger if clickable
    );

    if (!isIconClickable) return iconWidget;

    return Tooltip(
      message: iconTooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onIconTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: (iconColor ?? Theme.of(context).colorScheme.primary)
                .withOpacity(0.1),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
