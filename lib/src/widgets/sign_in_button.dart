import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final String type;
  final String assetName;
  final VoidCallback? onPressed;
  final BoxConstraints constraints;
  final bool enabled;

  const SignInButton({
    super.key,
    required this.text,
    required this.type,
    required this.assetName,
    required this.onPressed,
    required this.constraints,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    double buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(constraints);
    double fontSize = ResponsiveUtils.getResponsiveFontSize(constraints);
    double iconSize = ResponsiveUtils.getResponsiveIconSize(constraints);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: enabled ? Colors.black : Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/$assetName",
              width: iconSize,
              height: iconSize,
              color: enabled ? null : Colors.grey,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(constraints)),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
