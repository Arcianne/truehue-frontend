import 'package:flutter/material.dart';

import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';


class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? fontSize;
  final IconData? icon;
  final double? iconSize;
  final bool softWrap;
  final double? padding;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height,
    this.width,
    this.icon,
    this.iconSize,
    this.fontSize,
    this.softWrap = true,
    this.padding,
  });

    @override
    Widget build(BuildContext context) {
        return SizedBox(
          height: height ?? 40,
          width: width ?? 85,
          child: ElevatedButton.icon(
            // onPressed: onPressed,
            icon: icon != null
                ? Icon(icon, size: iconSize ?? 20)
                : const SizedBox.shrink(),
            label: Text(
              title,
              softWrap: softWrap,
              style: TextStyle(fontSize: fontSize ?? 19),
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

void openARLiveView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ARLiveViewPage()),
  );
}