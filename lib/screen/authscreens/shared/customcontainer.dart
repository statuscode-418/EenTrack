import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String text;
  final Color? labelColor;
  final Color? containerColor;

  const CustomContainer({
    Key? key,
    required this.text,
    this.labelColor,
    this.containerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: containerColor ?? Colors.grey,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
