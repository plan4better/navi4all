import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/common/sheet_button.dart';

class ReroutingDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ReroutingDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                AppLocalizations.of(context)!.routingScreenReroutingDialogTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.routingScreenReroutingDialogMessage,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: AppLocalizations.of(
                      context,
                    )!.routingScreenReroutingDialogCancelButton,
                    onTap: onCancel,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SheetButton(
                    label: AppLocalizations.of(
                      context,
                    )!.routingScreenReroutingDialogConfirmButton,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
