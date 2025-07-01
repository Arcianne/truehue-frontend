import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? fontSize;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height,
    this.width,
    this.icon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      width: width ?? 85,
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(title,
          style:TextStyle(fontSize: fontSize ?? 19),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCEF5FF),
          foregroundColor: const Color(0xFF130E64),
          fixedSize: Size(width ?? 85, height ?? 31),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}