import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/geometry.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/schemas/routing/place.dart';

class OrigDestPicker extends StatefulWidget {
  final Place? origin;
  final Place? destination;
  final Function onOriginTap;
  final Function onDestinationTap;
  final Function onOriginDestinationSwap;

  const OrigDestPicker({
    super.key,
    required this.origin,
    required this.destination,
    required this.onOriginTap,
    required this.onDestinationTap,
    required this.onOriginDestinationSwap,
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
            Semantics(
              label: AppLocalizations.of(context)!.origDestPickerOriginSemantic(
                widget.origin != null
                    ? widget.origin!.id == Navi4AllValues.userLocation
                          ? AppLocalizations.of(
                              context,
                            )!.origDestCurrentLocation
                          : widget.origin!.name
                    : AppLocalizations.of(context)!.origDestCurrentLocation,
              ),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => widget.onOriginTap(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEDEB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Navi4AllGeometry.radiusMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.origin == null
                            ? Icons.help_outline
                            : widget.origin!.id == Navi4AllValues.userLocation
                            ? Icons.my_location
                            : Icons.place_rounded,
                        color: Navi4AllColors.klRed,
                        size: Navi4AllGeometry.iconSizeMedium,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.origin == null
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : widget.origin!.id == Navi4AllValues.userLocation
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : widget.origin!.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 2, color: Navi4AllColors.klRed),
            Semantics(
              label: AppLocalizations.of(context)!
                  .origDestPickerDestinationSemantic(
                    widget.destination != null
                        ? widget.destination!.id == Navi4AllValues.userLocation
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : widget.destination!.name
                        : AppLocalizations.of(context)!.origDestCurrentLocation,
                  ),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => widget.onDestinationTap(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEDEB),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(Navi4AllGeometry.radiusMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.destination == null
                            ? Icons.help_outline
                            : widget.destination!.id ==
                                  Navi4AllValues.userLocation
                            ? Icons.my_location
                            : Icons.place_rounded,
                        color: Navi4AllColors.klRed,
                        size: Navi4AllGeometry.iconSizeMedium,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.destination == null
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : widget.destination!.id ==
                                    Navi4AllValues.userLocation
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : widget.destination!.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 8.0),
      Semantics(
        label: AppLocalizations.of(context)!.origDestPickerSwapButtonSemantic,
        excludeSemantics: true,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Navi4AllColors.klPink,
            iconSize: Navi4AllGeometry.iconSizeMedium,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => widget.onOriginDestinationSwap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Icon(Icons.swap_vert),
          ),
        ),
      ),
    ],
  );
}
