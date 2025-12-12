import 'package:flutter/material.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/feedback/feedback_type.dart';
import 'package:smartroots/view/common/selection_tile.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FeedbackType _selectedFeedbackType = FeedbackType.unselected;
  ProcessingStatus _submissionStatus = ProcessingStatus.idle;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedFeedbackType = FeedbackType.unselected;
      _submissionStatus = ProcessingStatus.idle;
    });
    _subjectController.clear();
    _messageController.clear();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate() ||
        _submissionStatus != ProcessingStatus.idle) {
      return;
    }

    String messageBody = '';
    if (_selectedFeedbackType != FeedbackType.unselected) {
      messageBody +=
          '${AppLocalizations.of(context)!.feedbackTypeHint}: ${_selectedFeedbackType.name}\n\n';
    }
    messageBody +=
        '${AppLocalizations.of(context)!.feedbackSubjectHint}: ${_subjectController.text}\n\n';
    messageBody +=
        '${AppLocalizations.of(context)!.feedbackMessageHint}: ${_messageController.text}\n\n';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Settings.supportEmailUrl,
      query: 'subject=${Settings.feedbackEmailSubject}&body=$messageBody',
    );

    await launchUrl(emailLaunchUri);

    // TODO: Enable with direct feedback submission
    /* setState(() {
      _submissionStatus = ProcessingStatus.processing;
    });

    setState(() {
      _submissionStatus = ProcessingStatus.completed;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoonMessage),
      ),
    ); */

    // Reset form after submission
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Row(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.arrow_back,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.feedbackScreenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.feedbackTypeHint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: [
                            SelectionTile(
                              leadingIcon: Icons.place_outlined,
                              title: AppLocalizations.of(
                                context,
                              )!.feedbackTypeLocalData,
                              isSelected:
                                  _selectedFeedbackType ==
                                  FeedbackType.localData,
                              onTap: () {
                                setState(() {
                                  _selectedFeedbackType =
                                      FeedbackType.localData;
                                });
                              },
                            ),
                            SizedBox(height: 8),
                            SelectionTile(
                              leadingIcon: Icons.phone_android_outlined,
                              title: AppLocalizations.of(
                                context,
                              )!.feedbackTypeAppFunctionality,
                              isSelected:
                                  _selectedFeedbackType ==
                                  FeedbackType.appFunctionality,
                              onTap: () {
                                setState(() {
                                  _selectedFeedbackType =
                                      FeedbackType.appFunctionality;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.feedbackSubjectHint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _subjectController,
                          enabled: _submissionStatus == ProcessingStatus.idle,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: '...',
                            hintStyle: TextStyle(
                              color: SmartRootsColors.maBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.feedbackFieldErrorRequired
                              : null,
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.feedbackMessageHint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          enabled: _submissionStatus == ProcessingStatus.idle,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: '...',
                            hintStyle: TextStyle(
                              color: SmartRootsColors.maBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.feedbackFieldErrorRequired
                              : null,
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.feedbackImageTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.feedbackImageHint,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SheetButton(
                              onTap: _resetForm,
                              icon: Icons.clear_rounded,
                              label: AppLocalizations.of(
                                context,
                              )!.feedbackResetButton,
                            ),
                            SizedBox(width: 16),
                            SheetButton(
                              onTap: _submitFeedback,
                              icon: Icons.send_rounded,
                              label: AppLocalizations.of(
                                context,
                              )!.feedbackSubmitButton,
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
