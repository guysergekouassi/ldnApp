import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color ?? kCardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: child,
    );
  }
}
