import 'package:flutter/material.dart';

import '../constants.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = kPrimaryColor,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.75),
  }) : super(key: key);

  final String text;
  final VoidCallback press;
  final color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
<<<<<<< HEAD
      shape: const RoundedRectangleBorder(
=======
      shape: RoundedRectangleBorder(
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      padding: padding,
      color: color,
      minWidth: double.infinity,
      onPressed: press,
      child: Text(
        text,
<<<<<<< HEAD
        style: const TextStyle(color: Colors.white),
=======
        style: TextStyle(color: Colors.white),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
      ),
    );
  }
}
