import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';

class SheetButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final bool shrinkWrap;

  const SheetButton({
    super.key,
    this.label,
    required this.onTap,
    this.semanticLabel,
    this.icon,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: SmartRootsColors.maBlueLight,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
            children: [
              icon != null
                  ? Icon(
                      icon,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                      size: 20,
                    )
                  : const SizedBox.shrink(),
              icon != null ? const SizedBox(width: 4) : const SizedBox.shrink(),
              label != null
                  ? Flexible(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: SmartRootsColors.maBlueExtraExtraDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

enum AccessibleButtonStyle { white, pink, red }
