import 'package:flutter/material.dart';
import '../constants.dart';

class RoundedCard extends StatelessWidget {
  final Widget child;
  const RoundedCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: K.cardRadius),
      elevation: Theme.of(context).cardTheme.elevation ?? 0,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
