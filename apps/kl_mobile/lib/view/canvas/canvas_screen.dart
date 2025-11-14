import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/view/canvas/canvas_map.dart';
import 'package:navi4all/view/canvas/canvas_sheet.dart';
import 'package:navi4all/view/itinerary/itinerary.dart';
import 'package:provider/provider.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final Map<CanvasControllerState, Widget> _overlayWidgets = {
    CanvasControllerState.home: Container(),
    CanvasControllerState.place: Container(),
    CanvasControllerState.itinerary: OrigDestPicker(),
    CanvasControllerState.navigating: Container(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CanvasMap(),
          CanvasSheet(),
          Consumer<CanvasController>(
            builder: (context, canvasController, _) =>
                SafeArea(child: _overlayWidgets[canvasController.state]!),
          ),
        ],
      ),
    );
  }
}
