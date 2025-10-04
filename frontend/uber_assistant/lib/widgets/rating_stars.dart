import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating; // 0-5
  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    final icons = List<Widget>.generate(5, (i) {
      if (i < full) return const Icon(Icons.star, size: 16);
      if (i == full && half) return const Icon(Icons.star_half, size: 16);
      return const Icon(Icons.star_border, size: 16);
    });
    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }
}
