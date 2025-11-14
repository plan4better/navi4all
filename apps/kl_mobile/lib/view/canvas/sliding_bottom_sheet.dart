import 'package:flutter/material.dart';

class SlidingBottomSheet extends StatefulWidget {
  final Widget stickyHeader;
  final Widget Function(BuildContext, ScrollController) listViewBuilder;
  final double minSize;
  final double initSize;
  final double maxSize;

  const SlidingBottomSheet({
    super.key,
    required this.stickyHeader,
    required this.listViewBuilder,
    this.minSize = 0.3,
    this.initSize = 0.45,
    this.maxSize = 0.75,
  });

  @override
  State<SlidingBottomSheet> createState() => _SlidingBottomSheetState();
}

class _SlidingBottomSheetState extends State<SlidingBottomSheet> {
  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DraggableScrollableSheet(
      minChildSize: widget.minSize,
      initialChildSize: widget.initSize,
      maxChildSize: widget.maxSize,
      builder: ((BuildContext context, ScrollController controller) => Material(
        elevation: 4.0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.0),
              Container(
                width: 32.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SingleChildScrollView(
                controller: controller,
                child: widget.stickyHeader,
              ),
              Expanded(child: widget.listViewBuilder(context, controller)),
            ],
          ),
        ),
      )),
    ),
  );
}
