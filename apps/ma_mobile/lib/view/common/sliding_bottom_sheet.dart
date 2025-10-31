import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';

class SlidingBottomSheet extends StatelessWidget {
  final Widget stickyHeader;
  final List<Widget>? listItems;
  final Widget? body;
  final double minSize;
  final double initSize;
  final double maxSize;

  SlidingBottomSheet(
    this.stickyHeader, {
    super.key,
    this.listItems,
    this.body,
    this.minSize = 0.3,
    this.initSize = 0.45,
    this.maxSize = 0.75,
  }) {
    assert(listItems != null || body != null);
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DraggableScrollableSheet(
      minChildSize: minSize,
      initialChildSize: initSize,
      maxChildSize: maxSize,
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
                child: stickyHeader,
              ),
              listItems != null
                  ? Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: listItems!.length,
                        itemBuilder: (BuildContext context, int index) =>
                            listItems![index],
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                              height: 1,
                              color: SmartRootsColors.maBlue,
                              indent: 16,
                              endIndent: 16,
                            ),
                      ),
                    )
                  : SizedBox.shrink(),
              body != null
                  ? SingleChildScrollView(controller: controller, child: body!)
                  : SizedBox.shrink(),
            ],
          ),
        ),
      )),
    ),
  );
}
