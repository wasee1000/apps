import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets contentPadding;
  final double borderRadius;
  final bool filled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final bool isDense;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconData,
    this.suffixIconData,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.borderRadius = 8.0,
    this.filled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.isDense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine colors based on theme and props
    final defaultFillColor = theme.brightness == Brightness.dark
        ? theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface
        : theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50;
    
    final defaultBorderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    
    final defaultFocusedBorderColor = theme.colorScheme.primary;
    final defaultErrorBorderColor = theme.colorScheme.error;
    
    // Build prefix icon if provided
    Widget? prefix;
    if (prefixIcon != null) {
      prefix = prefixIcon;
    } else if (prefixIconData != null) {
      prefix = Icon(
        prefixIconData,
        size: 20,
        color: theme.brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
      );
    }
    
    // Build suffix icon if provided
    Widget? suffix;
    if (suffixIcon != null) {
      suffix = suffixIcon;
    } else if (suffixIconData != null) {
      suffix = Icon(
        suffixIconData,
        size: 20,
        color: theme.brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
      );
    }
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      style: style ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        isDense: isDense,
        filled: filled,
        fillColor: fillColor ?? defaultFillColor,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: contentPadding,
        labelStyle: labelStyle ?? theme.inputDecorationTheme.labelStyle,
        hintStyle: hintStyle ?? theme.inputDecorationTheme.hintStyle,
        errorStyle: errorStyle ?? theme.inputDecorationTheme.errorStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? defaultFocusedBorderColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: errorBorderColor ?? defaultErrorBorderColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: errorBorderColor ?? defaultErrorBorderColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}

