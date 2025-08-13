import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final card = Theme.of(context).cardTheme;
    final radius = (card.shape as RoundedRectangleBorder?)?.borderRadius ??
        BorderRadius.circular(24);
    final side = (card.shape as RoundedRectangleBorder?)?.side ??
        BorderSide.none;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: card.color ?? Colors.white.withOpacity(.08),
        borderRadius: radius,
        border: Border.fromBorderSide(side), // ✅ converts BorderSide -> BoxBorder
      ),
      child: child,
    );
  }
}