import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

class TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppConstants.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: AppConstants.primaryColor, size: 30),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppConstants.heading3),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppConstants.caption),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppConstants.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
