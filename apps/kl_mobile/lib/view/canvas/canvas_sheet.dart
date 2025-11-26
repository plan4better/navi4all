import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/view/canvas/sliding_bottom_sheet.dart';
import 'package:navi4all/view/itinerary/itinerary.dart';
import 'package:navi4all/view/place/place.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/view/alt/place/place.dart' as alt_place;

class CanvasSheet extends StatefulWidget {
  final bool altMode;

  const CanvasSheet({super.key, this.altMode = false});

  @override
  State<CanvasSheet> createState() => _CanvasSheetState();
}

class _CanvasSheetState extends State<CanvasSheet> {
  final Map<CanvasControllerState, Widget> _stickyWidgets = {
    CanvasControllerState.home: Container(),
    CanvasControllerState.place: PlaceScreen(),
    CanvasControllerState.itinerary: ItineraryScreen(),
    CanvasControllerState.navigating: Container(),
  };

  final Map<CanvasControllerState, Widget> _stickyWidgetsAltMode = {
    CanvasControllerState.home: Container(),
    CanvasControllerState.place: alt_place.PlaceScreen(),
    CanvasControllerState.itinerary: ItineraryScreen(),
    CanvasControllerState.navigating: Container(),
  };

  final Map<CanvasControllerState, Type> _builderWidgets = {
    CanvasControllerState.home: Container,
    CanvasControllerState.place: Container,
    CanvasControllerState.itinerary: ItineraryList,
    CanvasControllerState.navigating: Container,
  };

  @override
  Widget build(BuildContext context) => Consumer<CanvasController>(
    builder: (context, canvasController, child) {
      return !widget.altMode
          ? SlidingBottomSheet(
              stickyHeader: _stickyWidgets[canvasController.state]!,
              listViewBuilder: (context, controller) =>
                  _builderWidgets[canvasController.state] == ItineraryList
                  ? ItineraryList(scrollController: controller)
                  : Container(),
              initSize: 0.4,
              maxSize: 0.75,
            )
          : Container(child: _stickyWidgetsAltMode[canvasController.state]!);
    },
  );
}
