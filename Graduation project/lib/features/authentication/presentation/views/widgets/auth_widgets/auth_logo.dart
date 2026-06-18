import 'package:flutter/material.dart';
import 'package:pickutopia/core/utils/assets.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Image(
        width: 300,
        height: 300,
        image: AssetImage(
          AssetsData.authLogo,
        ),
      ),
    );
  }
}
