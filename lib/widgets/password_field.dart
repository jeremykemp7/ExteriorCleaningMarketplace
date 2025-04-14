import 'package:flutter/material.dart';
import '../theme.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final Color? iconColor;
  final Color? fillColor;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.validator,
    this.style,
    this.labelStyle,
    this.iconColor,
    this.fillColor,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscureText,
      style: widget.style,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: widget.labelStyle,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.fillColor ?? Colors.white.withOpacity(0.05),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: widget.iconColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
} 