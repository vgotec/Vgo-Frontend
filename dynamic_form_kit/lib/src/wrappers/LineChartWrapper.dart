import 'package:dynamic_form_kit/src/widget_collection/LineChartWidget.dart';
import 'package:flutter/material.dart';
import '../manager/form_state_manager.dart';
import '../utils/style_parser.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class LineChartWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const LineChartWrapper({
    super.key,
    required this.field,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final config = field['config'] ?? {};
    final style = config['style'] ?? {};
    final chartOptions = config['chartOptions'] ?? {};
    final data = config['data'] ?? field['data'] ?? {};


    final bg = StyleParser.parseColor(style['backgroundColor'], Colors.white);
    final height = StyleParser.parseDouble(style['height'], 240);
    final padding = StyleParser.parseDouble(style['padding'], 12);
    final margin = StyleParser.parseDouble(style['margin'], 8);
    final radius = StyleParser.parseDouble(style['borderRadius'], 12);

    final lineColor = StyleParser.parseColor(style['lineColor'], Colors.blue);
    final thickness = StyleParser.parseDouble(chartOptions['lineThickness'], 3);
    final markers = chartOptions['markerVisibility'] != false;
    final duration = Duration(
      milliseconds: chartOptions['animationDuration'] ?? 600,
    );

    return Container(
      height: height,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field['title'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                field['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StyleParser.parseColor(style['titleColor'], Colors.black),
                ),
              ),
            ),
          Expanded(
            child: LeaveLineChart(
              data: data,
              lineColor: lineColor,
              lineThickness: thickness,
              showMarkers: markers,
              animationDuration: duration,
            ),
          ),
        ],
      ),
    );
  }
}
