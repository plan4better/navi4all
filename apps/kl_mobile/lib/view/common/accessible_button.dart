import 'package:flutter/material.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'package:navi4all/util/theme/geometry.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final AccessibleButtonStyle style;
  final VoidCallback onTap;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: style == AccessibleButtonStyle.white
            ? Navi4AllColors.klWhite
            : style == AccessibleButtonStyle.pink
            ? Navi4AllColors.klPink
            : Navi4AllColors.klRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Navi4AllGeometry.radiusLarge),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      ),
      child: SizedBox(
        width: 256.0,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Navi4AllGeometry.fontSizeMedium,
            color:
                (style == AccessibleButtonStyle.white) |
                    (style == AccessibleButtonStyle.pink)
                ? Navi4AllColors.klRed
                : Navi4AllColors.klWhite,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

enum AccessibleButtonStyle { white, pink, red }
