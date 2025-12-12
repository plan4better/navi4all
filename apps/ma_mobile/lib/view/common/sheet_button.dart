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
      button: true,
      child: Material(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                icon != null && label != null
                    ? const SizedBox(width: 8)
                    : const SizedBox.shrink(),
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
      ),
    );
  }
}

enum SheetButtonStyle { white, pink, red }
