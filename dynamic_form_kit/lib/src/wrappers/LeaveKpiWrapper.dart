import 'package:flutter/material.dart';
import '../manager/form_state_manager.dart';
import '../utils/style_parser.dart';
import '../widget_collection/KpiCardGroupWidget.dart';

class LeaveKpiWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const LeaveKpiWrapper({
    super.key,
    required this.field,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final config = field["config"] ?? {};
    final style = config["style"] ?? {};
    final data = config["data"] ?? field["data"] ?? [];

    return Container(
      height: StyleParser.parseDouble(style["height"], 250),
      margin: EdgeInsets.all(StyleParser.parseDouble(style["margin"], 12)),
      padding: EdgeInsets.all(StyleParser.parseDouble(style["padding"], 12)),
      decoration: BoxDecoration(
        color: StyleParser.parseColor(style["backgroundColor"], Colors.white),
        borderRadius:
            BorderRadius.circular(StyleParser.parseDouble(style["borderRadius"], 16)),
      ),
      child: KpiCardGroupWidget(
        kpiItems: List<Map<String, dynamic>>.from(data),
        cardColor: StyleParser.parseColor(style["kpiCardColor"], Colors.white),
        titleColor: StyleParser.parseColor(style["kpiTitleColor"], Colors.black),
        valueColor: StyleParser.parseColor(style["kpiValueColor"], Colors.blue),
        spacing: 12,
        cardHeight: 110,
        borderRadius: 16,
      ),
    );
  }
}
