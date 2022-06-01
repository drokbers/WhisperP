import 'package:flutter/material.dart';

class ButtonBack extends StatelessWidget {
  const ButtonBack({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.width,
    required this.height,
    required this.iconSize,
  }) : super(key: key);

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final double width;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          width: 1,
          color: borderColor,
        ),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        padding: const EdgeInsets.all(0),
        icon: Icon(
          Icons.chevron_left,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
