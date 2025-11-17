import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';

class SelectionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final String? subtitle;
  final String? leadingImage;
  final IconData? leadingIcon;
  final VoidCallback onTap;

  SelectionTile({
    super.key,
    required this.title,
    required this.isSelected,
    this.subtitle,
    this.leadingImage,
    this.leadingIcon,
    required this.onTap,
  }) {
    assert(
      leadingImage == null || leadingIcon == null,
      'Only one of leadingImage or leadingIcon can be provided.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Navi4AllColors.klLightRed : Colors.transparent,
      borderRadius: BorderRadius.circular(32.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(color: Navi4AllColors.klPink, width: 1.0),
          ),
          child: Row(
            children: [
              leadingIcon != null || leadingImage != null
                  ? SizedBox(width: 8.0)
                  : SizedBox.shrink(),
              leadingIcon != null
                  ? Icon(
                      leadingIcon!,
                      color: Theme.of(context).textTheme.displayMedium?.color,
                    )
                  : leadingImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.0),
                      child: Image.asset(leadingImage!, width: 32, height: 32),
                    )
                  : SizedBox.shrink(),
              SizedBox(width: 12.0),
              Column(
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle != null ? SizedBox(height: 4.0) : SizedBox.shrink(),
                  subtitle != null
                      ? Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
