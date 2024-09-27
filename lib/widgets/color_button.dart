import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final void Function() onTap;

  const ColorButton(this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        color: color,
      ),
    );
  }
}
