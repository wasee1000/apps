import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final EdgeInsets padding;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
    this.borderRadius = 8.0,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button style based on props
    final bgColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : theme.colorScheme.primary);
    
    final txtColor = textColor ?? 
        (isOutlined ? theme.colorScheme.primary : Colors.white);
    
    final borderColor = isOutlined ? theme.colorScheme.primary : Colors.transparent;
    
    // Build button
    Widget buttonChild;
    
    if (isLoading) {
      // Loading state
      buttonChild = SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(txtColor),
        ),
      );
    } else if (icon != null) {
      // Button with icon and text
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: txtColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: txtColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      // Text only button
      buttonChild = Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: txtColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    // Create button with gradient if not outlined
    if (!isOutlined && backgroundColor == null && !isLoading && onPressed != null) {
      return Container(
        width: isFullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: txtColor,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }
    
    // Regular button (outlined or solid)
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: txtColor,
                side: BorderSide(color: borderColor),
                padding: padding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: txtColor,
                padding: padding,
                elevation: onPressed != null ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: buttonChild,
            ),
    );
  }
}

