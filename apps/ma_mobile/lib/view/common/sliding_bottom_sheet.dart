import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';

class SlidingBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> _listItems;

  const SlidingBottomSheet(
    this.title,
    this.subtitle,
    this._listItems, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DraggableScrollableSheet(
      minChildSize: 0.3,
      initialChildSize: 0.45,
      maxChildSize: 0.75,
      builder: ((BuildContext context, ScrollController controller) => Material(
        elevation: 4.0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: SmartRootsColors.maWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                controller: controller,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 32.0,
                              height: 4.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  controller: controller,
                  shrinkWrap: true,
                  itemCount: _listItems.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _listItems[index],
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                        height: 1,
                        color: SmartRootsColors.maBlue,
                        indent: 16,
                        endIndent: 16,
                      ),
                ),
              ),
            ],
          ),
        ),
      )),
    ),
  );
}
