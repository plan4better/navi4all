import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';

class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasNotification;
  final String? semanticLabel;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasNotification = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    excludeSemantics: true,
    button: true,
    child: Stack(
      children: [
        Ink(
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          child: IconButton(
            icon: Stack(
              children: [
                Icon(icon, color: SmartRootsColors.maBlueExtraExtraDark),
              ],
            ),
            onPressed: onTap,
            tooltip: semanticLabel,
          ),
        ),
        hasNotification
            ? Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 8, left: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).textTheme.displayMedium?.color,
                ),
              )
            : SizedBox.shrink(),
      ],
    ),
  );
}
