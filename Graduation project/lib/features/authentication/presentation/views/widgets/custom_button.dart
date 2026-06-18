import 'package:flutter/material.dart';
import 'package:pickutopia/core/utils/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
  });

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 15,
          backgroundColor: kMainColor,
          minimumSize: const Size(400, 60),
          maximumSize: const Size(400, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
      onPressed: onPressed,
      child: child,
    );
  }
}
