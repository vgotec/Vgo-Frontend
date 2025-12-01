import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LeaveLineChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color lineColor;
  final double lineThickness;
  final bool showMarkers;
  final Duration animationDuration;

  const LeaveLineChart({
    super.key,
    required this.data,
    required this.lineColor,
    required this.lineThickness,
    required this.showMarkers,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final raw = Map<String, dynamic>.from(data);
    final Map<String, dynamic> monthly = Map<String, dynamic>.from(raw['monthlyLeaveDays'] ?? {});

    final List<_LeavePoint> points = monthly.entries.map((e) {
      final month = int.tryParse(e.key) ?? 0;
      final value = (e.value is num) ? e.value.toDouble() : 0.0;
      return _LeavePoint(month, value);
    }).toList();

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        interval: 1,
        title: AxisTitle(text: "Month"),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: "Leave Days"),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: [
        LineSeries<_LeavePoint, int>(
          dataSource: points,
          xValueMapper: (p, _) => p.month,
          yValueMapper: (p, _) => p.value,
          color: lineColor,
          width: lineThickness,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
          ),
          animationDuration: animationDuration.inMilliseconds.toDouble(),
        ),
      ],
    );
  }
}

class _LeavePoint {
  final int month;
  final double value;
  _LeavePoint(this.month, this.value);
}
