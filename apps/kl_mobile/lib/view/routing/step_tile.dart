import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/leg.dart' as leg_schema;
import 'package:navi4all/schemas/routing/mode.dart';

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
                    ? Navi4AllColors.klRed
                    : Navi4AllColors.klPink,
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
                        color: Navi4AllColors.klRed,
                      ),
                    ),
                    !step.bogusName
                        ? Text(
                            step.streetName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Navi4AllColors.klRed,
                            ),
                          )
                        : SizedBox.shrink(),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.navigationStepDistanceToAction(
                        TextFormatter.formatDistanceValueText(step.distance),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Navi4AllColors.klRed),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          step != activeStep
              ? Divider(color: Navi4AllColors.klPink, height: 0.0)
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
