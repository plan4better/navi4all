import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/utils.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;
import 'package:smartroots/schemas/routing/mode.dart';

class StepTile extends StatelessWidget {
  final leg_schema.Step step;
  final leg_schema.Step? activeStep;

  const StepTile({super.key, required this.step, this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: step == activeStep
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                getRelativeDirectionIconMapping(step.relativeDirection),
                color: step == activeStep
                    ? SmartRootsColors.maBlueExtraExtraDark
                    : SmartRootsColors.maBlue,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getRelativeDirectionTextMapping(
                        step.relativeDirection,
                        context,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    !step.bogusName
                        ? Text(
                            step.streetName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                          )
                        : SizedBox.shrink(),
                    step.relativeDirection != RelativeDirection.DEPART
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.navigationStepDistanceToAction(
                              TextFormatter.formatDistanceValueText(
                                step.distance,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          step != activeStep
              ? Divider(color: SmartRootsColors.maBlue, height: 0.0)
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
