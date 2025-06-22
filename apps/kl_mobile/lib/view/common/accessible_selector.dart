import 'package:flutter/material.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'package:navi4all/util/theme/geometry.dart';

class AccessibleSelector extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AccessibleSelector({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 288.0,
        decoration: BoxDecoration(
          color: selected ? Navi4AllColors.klWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(Navi4AllGeometry.radiusMedium),
          border: Border.all(
            color: Colors.white,
            width: Navi4AllGeometry.thickness,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Navi4AllGeometry.fontSizeMedium,
            color: selected ? Navi4AllColors.klRed : Navi4AllColors.klWhite,
            // Optionally, you can change color if selected
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
