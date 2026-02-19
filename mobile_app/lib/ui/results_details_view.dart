import 'package:flutter/material.dart';
import 'dart:io';
import 'theme/app_theme.dart';
import '../logic/treatment_translations.dart';
import '../logic/language_service.dart';

class ResultsDetailsView extends StatefulWidget {
  final Map<String, dynamic> result;
  final File? image;

  const ResultsDetailsView({
    required this.result,
    this.image,
  });

  @override
  _ResultsDetailsViewState createState() => _ResultsDetailsViewState();
}

class _ResultsDetailsViewState extends State<ResultsDetailsView> {
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final confidence = result['confidence'] ?? 0.0;
    final label = result['hindi_name'] ?? result['label'] ?? 'Unknown';
    final actionPlan = result['action_plan'] ?? [];
    final treatmentDays = result['treatment_days'] ?? '7'; // Default to 7 days
    
    // Get current language for translations
    final currentLanguage = LanguageService.currentLanguage;
    
    Color resultColor = confidence > 0.7 ? AppTheme.dangerColor : AppTheme.warningColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("Analysis Result"),
        subtitle: Text(TreatmentTranslations.translate(currentLanguage, 'titles', 'action_plan')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            if (widget.image != null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: Image.file(
                  widget.image!,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Result Status Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            resultColor.withOpacity(0.1),
                            resultColor.withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: resultColor.withOpacity(0.2),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: resultColor,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Detected",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Treatment Duration Card (Multilingual)
                  _buildTreatmentDurationCard(treatmentDays, currentLanguage, resultColor),
                  SizedBox(height: 20),

                  // Confidence Score
                  _buildInfoSection(
                    title: "Confidence Score",
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: confidence,
                            backgroundColor: AppTheme.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              confidence > 0.8 ? AppTheme.dangerColor : AppTheme.warningColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "${(confidence * 100).toStringAsFixed(1)}% confident",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Detailed Information
                  _buildInfoSection(
                    title: TreatmentTranslations.translate(currentLanguage, 'titles', 'action_plan'),
                    child: Text(
                      result['description'] ?? TreatmentTranslations.getCureDescription(treatmentDays, currentLanguage),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Severity Level (Multilingual)
                  _buildInfoSection(
                    title: TreatmentTranslations.translate(currentLanguage, 'titles', 'severity'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: resultColor),
                      ),
                      child: Text(
                        TreatmentTranslations.getSeverity(
                          confidence > 0.8 ? 'high' : 'medium',
                          currentLanguage,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Recommended Actions (Multilingual)
                  Text(
                    TreatmentTranslations.translate(currentLanguage, 'titles', 'action_plan'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (actionPlan is List && actionPlan.isNotEmpty)
                    ...actionPlan.asMap().entries.map<Widget>((entry) {
                      int idx = entry.key + 1;
                      String action = entry.value.toString();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  idx.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "No specific actions recommended",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text("Share"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Result shared successfully")),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.save),
                          label: Text("Save"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Result saved to history")),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build treatment duration card with multilingual support
  Widget _buildTreatmentDurationCard(String days, String language, Color resultColor) {
    final cureDuration = TreatmentTranslations.getCureDuration(days, language);
    final cureDescription = TreatmentTranslations.getCureDescription(days, language);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.primaryColor.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.schedule,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TreatmentTranslations.translate(language, 'titles', 'cure_duration'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        cureDuration,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              cureDescription,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: child,
          ),
        ),
      ],
    );
  }
}
