import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/theme/geometry.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String? semanticLabel;
  final AccessibleButtonStyle style;
  final VoidCallback? onTap;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.style,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: style == AccessibleButtonStyle.white
              ? SmartRootsColors.maWhite
              : style == AccessibleButtonStyle.pink
              ? SmartRootsColors.maBlue
              : SmartRootsColors.maBlueExtraDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Navi4AllGeometry.radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
        ),
        child: SizedBox(
          width: 160.0,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color:
                  (style == AccessibleButtonStyle.white) |
                      (style == AccessibleButtonStyle.pink)
                  ? SmartRootsColors.maBlueExtraDark
                  : SmartRootsColors.maWhite,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

enum AccessibleButtonStyle { white, pink, red }
