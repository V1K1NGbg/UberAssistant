import 'package:flutter/material.dart';
import '../constants.dart';

class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const RoundedCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
