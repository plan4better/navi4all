import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'package:navi4all/view/routing/route_navigation.dart';

class JourneyOption extends StatelessWidget {
  final String duration;
  final String startTime;
  final String endTime;
  final List<Map<String, dynamic>> segments;
  final String address;
  final String zipcode;

  const JourneyOption({
    super.key,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.segments,
    required this.address,
    required this.zipcode,
  });

  String get _segmentsDescription {
    return segments
        .map((segment) {
          return '${segment['mode']} (${segment['duration']})';
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RouteNavigationScreen(
              address: address,
              zipcode: zipcode,
              duration: duration,
              startTime: startTime,
              endTime: endTime,
              segments: segments,
            ),
          ),
        );
      },
      child: Semantics(
        label: AppLocalizations.of(context)!.journeyOptionSemantic(
          duration,
          startTime,
          endTime,
          _segmentsDescription,
        ),
        child: Semantics(
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duration,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Navi4AllColors.klRed,
                  ),
                ),
                Text(
                  '$startTime - $endTime',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Navi4AllColors.klRed,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: segments.map((segment) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDEB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        margin: segment != segments.last
                            ? EdgeInsets.only(right: 4)
                            : EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              segment['icon'],
                              color: Color(0xFFD82028),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              segment['duration'],
                              style: const TextStyle(
                                color: Navi4AllColors.klRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Divider(thickness: 1, color: Navi4AllColors.klRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
