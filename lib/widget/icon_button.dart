import 'package:flutter/material.dart';

class ContainerIcon extends StatelessWidget {
  const ContainerIcon({
    required this.icon,
    this.onPressed,
    super.key,
  });

  final VoidCallback? onPressed;

  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: icon,
        ),
      ),
    );
  }
}
