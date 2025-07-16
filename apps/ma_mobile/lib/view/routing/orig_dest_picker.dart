import 'package:flutter/material.dart';
import 'package:smart_roots/l10n/app_localizations.dart';
import 'package:smart_roots/util/theme/colors.dart';
import 'package:smart_roots/util/theme/geometry.dart';

class OrigDestPicker extends StatefulWidget {
  final String origin;
  final String destination;

  const OrigDestPicker({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<StatefulWidget> createState() => _OrigDestPickerState();
}

class _OrigDestPickerState extends State<OrigDestPicker> {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDEB),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Navi4AllGeometry.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: Navi4AllColors.klRed,
                    size: Navi4AllGeometry.iconSizeMedium,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.origin,
                      semanticsLabel: AppLocalizations.of(
                        context,
                      )!.origDestPickerOriginSemantic(widget.origin),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 2, color: Navi4AllColors.klRed),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDEB),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(Navi4AllGeometry.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: Navi4AllColors.klRed,
                    size: Navi4AllGeometry.iconSizeMedium,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.destination,
                      semanticsLabel: AppLocalizations.of(
                        context,
                      )!.origDestPickerOriginSemantic(widget.origin),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 12.0),
      Semantics(
        label: AppLocalizations.of(context)!.origDestPickerSwapButtonSemantic,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Navi4AllColors.klPink,
            iconSize: Navi4AllGeometry.iconSizeMedium,
            padding: EdgeInsets.zero,
          ),
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Icon(Icons.swap_vert),
          ),
        ),
      ),
    ],
  );
}
