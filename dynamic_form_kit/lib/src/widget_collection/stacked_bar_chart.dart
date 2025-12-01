import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A stacked bar chart widget using the fl_chart package.
/// Input data structure:
/// {
///   "labels": ["1","2",...],
///   "series": { "Dev": [0,1,2,...], "Test":[...], ... },
///   "categories": ["Dev","Test", ...],
///   "maxValue": 8.0
/// }
class StackedBarChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, Color>? colors;
  final Map<String, dynamic>? chartOptions;
  final Duration animationDuration;

  const StackedBarChart({
    Key? key,
    required this.data,
    this.colors,
    this.chartOptions,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = List<String>.from(data['labels'] ?? []);
    final categories = List<String>.from(data['categories'] ?? []);
    final series = Map<String, List<double>>.from(data['series'] ?? {});
    final maxValue = (data['maxValue'] ?? 1.0).toDouble();

    final rawColors = colors ?? {};
    final Map<String, Color> colorMap = {};
    rawColors.forEach((k, v) {
      colorMap[k.toLowerCase()] = v;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // ✅ FINAL ATTEMPT FIX: Reverting to the 1-argument signature for getTooltipColor 
            // as demanded by the TypeError shown in the image.
            getTooltipColor: (
              BarChartGroupData group, 
            ) {
              return Colors.blueGrey.withOpacity(0.9);
            },
            
            // NOTE: The getTooltipItem should still use the 4-argument signature 
            // as it needs more detail to calculate the tooltip content.
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Total: ${rod.toY.toStringAsFixed(1)}h',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tooltipBorderRadius: BorderRadius.circular(8), 
          ),
        ),
        titlesData: _buildTitlesData(labels, categories, chartOptions),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          checkToShowHorizontalLine: (value) {
            // Show only on integer or specific markers (0, 4, 8, etc.)
            return value % 4 == 0 || value == 0;
          },
        ),
        barGroups: _buildBarGroups(labels, series, categories, colorMap),
        maxY: maxValue,
        groupsSpace: (chartOptions?['barSpacing'] is num) 
            ? (chartOptions!['barSpacing'] as num).toDouble() 
            : 20.0,
      ),
      swapAnimationDuration: animationDuration,
      swapAnimationCurve: Curves.easeOut,
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      List<String> labels,
      Map<String, List<double>> series,
      List<String> categories,
      Map<String, Color> colorMap) {
    List<BarChartGroupData> groups = [];
    final barRadius = (chartOptions?['barRadius'] is num) 
        ? (chartOptions!['barRadius'] as num).toDouble() 
        : 6.0;
    
    final double barWidth = (chartOptions?['barWidth'] is num) 
        ? (chartOptions!['barWidth'] as num).toDouble()
        : 15.0;

    for (int i = 0; i < labels.length; i++) {
      double stackBase = 0.0;
      List<BarChartRodStackItem> rodStacks = [];

      for (final cat in categories) {
        final values = series[cat] ?? [];
        final v = (i < values.length) ? values[i] : 0.0;
        
        if (v > 0) {
          final color = colorMap[cat.toLowerCase()] ?? _defaultColorFor(cat);
          rodStacks.add(BarChartRodStackItem(stackBase, stackBase + v, color));
          stackBase += v;
        }
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: stackBase,
              rodStackItems: rodStacks,
              borderRadius: BorderRadius.circular(barRadius),
              width: barWidth,
            ),
          ],
        ),
      );
    }
    return groups;
  }

  FlTitlesData _buildTitlesData(
      List<String> labels, List<String> categories, Map<String, dynamic>? chartOptions) {
    final showXAxis = chartOptions?['showXAxis'] != false;
    final xAxisLabelColor = _parseColor(chartOptions?['xAxisLabelColor']);
    final yAxisLabelColor = _parseColor(chartOptions?['yAxisLabelColor']);

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        axisNameWidget: const Text('Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        sideTitles: SideTitles(
          showTitles: showXAxis,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < labels.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  labels[index],
                  style: TextStyle(color: xAxisLabelColor, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Container();
          },
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: const Text('Hours', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 2.0, // Force intervals (e.g., 0, 2, 4, 6, 8)
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value == meta.min) return Container();
            return Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: yAxisLabelColor, fontSize: 10),
              textAlign: TextAlign.right,
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(dynamic c) {
    if (c is Color) return c;
    if (c is String) {
      final hex = c.replaceAll('#', '');
      try {
        final value = int.parse('FF$hex', radix: 16);
        return Color(value);
      } catch (_) {}
    }
    return Colors.black54;
  }

  Color _defaultColorFor(String key) {
    final hash = key.hashCode;
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return palette[(hash & 0x7fffffff) % palette.length].shade400;
  }
}