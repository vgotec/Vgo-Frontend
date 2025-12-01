import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class KpiCardGroupWidget extends StatelessWidget {
  final List<Map<String, dynamic>> kpiItems;
  final Color cardColor;
  final Color titleColor;
  final Color valueColor;
  final double cardHeight;
  final double spacing;
  final double borderRadius;

  const KpiCardGroupWidget({
    super.key,
    required this.kpiItems,
    required this.cardColor,
    required this.titleColor,
    required this.valueColor,
    this.cardHeight = 110,
    this.spacing = 12,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpiItems.length,
      itemBuilder: (context, index) {
        final item = kpiItems[index];
        final title = item["leaveTypeName"] ?? "N/A";
        final used = item["usedDays"] ?? 0;
        final remain = item["remainingDays"] ?? 0;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const Spacer(),
              Text(
                "Used: $used",
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Remaining: $remain",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
