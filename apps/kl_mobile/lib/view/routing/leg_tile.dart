import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/icons.dart';
import 'package:navi4all/schemas/routing/leg.dart' as leg_schema;
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/view/routing/step_tile.dart';

class LegTile extends StatelessWidget {
  final leg_schema.LegDetailed leg;
  final leg_schema.LegDetailed? activeLeg;
  final List<leg_schema.Step> steps;
  final leg_schema.Step? activeStep;
  final bool isPrimaryLeg;

  const LegTile({
    super.key,
    required this.leg,
    this.activeLeg,
    required this.steps,
    this.activeStep,
    this.isPrimaryLeg = false,
  });

  Widget _buildTransitWidget(BuildContext context) {
    return (leg.mode != Mode.WALK &&
            leg.mode != Mode.BICYCLE &&
            leg.mode != Mode.CAR)
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Navi4AllColors.klPink),
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Text(
              leg.route!.shortName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          )
        : SizedBox.shrink();
  }

  List<StepTile> _buildStepTiles(
    List<leg_schema.Step> steps,
    leg_schema.Step? activeStep,
  ) {
    List<StepTile> stepTiles = [];
    for (leg_schema.Step step in steps) {
      stepTiles.add(StepTile(step: step, activeStep: activeStep));
    }
    return stepTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: EdgeInsets.symmetric(
        horizontal: !isPrimaryLeg ? 8 : 0,
        vertical: !isPrimaryLeg ? 16 : 0,
      ),
      decoration: !isPrimaryLeg
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: leg == activeLeg
                    ? Navi4AllColors.klRed
                    : Navi4AllColors.klPink,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isPrimaryLeg
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        ModeIcons.get(leg.mode),
                        color: Navi4AllColors.klRed,
                      ),
                      SizedBox(width: 16),
                      Text(
                        getModeTextMapping(leg.mode, context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Navi4AllColors.klRed,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          !isPrimaryLeg ? SizedBox(height: 8) : SizedBox.shrink(),
          _buildTransitWidget(context),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            children: _buildStepTiles(steps, activeStep),
          ),
        ],
      ),
    );
  }
}
