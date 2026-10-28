import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../models/home_models.dart';

/// Single-select category chips. Selecting one filters the room grid.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RoomCategory selected;
  final ValueChanged<RoomCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        children: [
          for (final category in RoomCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 9),
              child: ChoiceChip(
                key: ValueKey('category-${category.name}'),
                label: Text(category.label),
                selected: category == selected,
                onSelected: (_) => onSelected(category),
                showCheckmark: false,
                selectedColor: OyaaroColors.yellow,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: category == selected
                      ? OyaaroColors.yellow
                      : OyaaroColors.chipBorder,
                  width: 1.5,
                ),
                labelStyle: const TextStyle(
                  color: OyaaroColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
            ),
        ],
      ),
    );
  }
}
