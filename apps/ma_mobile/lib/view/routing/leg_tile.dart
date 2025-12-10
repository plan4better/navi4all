import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/theme/icons.dart';
import 'package:smartroots/core/theme/labels.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/view/routing/step_tile.dart';

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
            leg.mode != Mode.SCOOTER &&
            leg.mode != Mode.CAR)
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              leg.route!.shortName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
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
                    ? SmartRootsColors.maBlue
                    : SmartRootsColors.maBlue,
              ),
            )
          : null,
      child: Column(
        children: [
          !isPrimaryLeg
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        ModeIcons.get(leg.mode),
                        color: SmartRootsColors.maBlue,
                      ),
                      SizedBox(width: 16),
                      Text(
                        SmartRootsLabels.getModeString(context, leg.mode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SmartRootsColors.maBlue,
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
