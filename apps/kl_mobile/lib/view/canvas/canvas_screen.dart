import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/canvas/canvas_map.dart';
import 'package:navi4all/view/canvas/canvas_sheet.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/view/itinerary/itinerary.dart';
import 'package:navi4all/view/place/place.dart';
import 'package:provider/provider.dart';

class CanvasScreen extends StatefulWidget {
  final bool altMode;

  const CanvasScreen({super.key, this.altMode = false});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final Map<CanvasControllerState, Widget> _overlayWidgets = {
    CanvasControllerState.home: Container(),
    CanvasControllerState.place: PlaceSearchBar(),
    CanvasControllerState.itinerary: OrigDestPicker(),
    CanvasControllerState.navigating: Container(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          !widget.altMode ? CanvasMap() : SizedBox.shrink(),
          CanvasSheet(altMode: widget.altMode),
          Consumer<CanvasController>(
            builder: (context, canvasController, _) =>
                SafeArea(child: _overlayWidgets[canvasController.state]!),
          ),
          widget.altMode
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: AccessibleButton(
                      label: AppLocalizations.of(
                        context,
                      )!.commonHomeScreenButton,
                      style: AccessibleButtonStyle.pink,
                      onTap: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
