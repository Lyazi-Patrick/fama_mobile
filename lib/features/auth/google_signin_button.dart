import 'package:flutter/material.dart';

/// Renders Google's own official "Continue with Google" button asset
/// (Light theme, pill shape, with text) rather than a hand-built
/// approximation. Per Google's Sign-In branding guidelines, this asset
/// should be used as-is -- not recolored, stretched, or recreated --
/// so this widget just makes it tappable at a comfortable touch-target
/// size without distorting its aspect ratio.
///
/// Source: the official "Sign in with Google" brand asset kit
/// (Android + Web / Light / Show text=Yes / Shape=Pill).
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed, this.enabled = true});

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: Image.asset(
                'assets/images/google_signin_button.png',
                height: 40,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
