import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/view/canvas/sliding_bottom_sheet.dart';
import 'package:navi4all/view/itinerary/itinerary.dart';
import 'package:navi4all/view/place/place.dart';
import 'package:provider/provider.dart';

class CanvasSheet extends StatefulWidget {
  const CanvasSheet({super.key});

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

  final Map<CanvasControllerState, Type> _builderWidgets = {
    CanvasControllerState.home: Container,
    CanvasControllerState.place: Container,
    CanvasControllerState.itinerary: ItineraryList,
    CanvasControllerState.navigating: Container,
  };

  @override
  Widget build(BuildContext context) => Consumer<CanvasController>(
    builder: (context, canvasController, child) {
      return SlidingBottomSheet(
        stickyHeader: _stickyWidgets[canvasController.state]!,
        listViewBuilder: (context, controller) =>
            _builderWidgets[canvasController.state] == ItineraryList
            ? ItineraryList(scrollController: controller)
            : Container(),
        initSize: 0.4,
        maxSize: 0.75,
      );
    },
  );
}
