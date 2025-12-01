import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../widget_collection/stacked_bar_chart.dart'; 
import '../manager/form_state_manager.dart';
import '../utils/style_parser.dart'; 


/// Wrapper that adapts your JSON field into the StackedBarChart widget.
class StackedBarWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext;

  const StackedBarWrapper({
    Key? key,
    required this.field,
    required this.manager,
    this.dataContext,
  }) : super(key: key);

  @override
  _StackedBarWrapperState createState() => _StackedBarWrapperState();
}

class _StackedBarWrapperState extends State<StackedBarWrapper> {
  Map<String, dynamic> _style = {};
  Map<String, dynamic> _chartOptions = {};
  Map<String, dynamic> _data = {};
  StreamSubscription<dynamic>? _actionSub;

  @override
  void initState() {
    super.initState();
    _readConfig();
    widget.manager.addListener(_onManagerChange);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChange);
    _actionSub?.cancel();
    super.dispose();
  }

  void _onManagerChange() {
    final old = _data;
    _readDataOnly();
    if (!_deepEquals(old, _data)) {
      setState(() {});
    }
  }

  bool _deepEquals(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final va = a[key], vb = b[key];
      if (va is Map && vb is Map) {
        if (!_deepEquals(Map<String, dynamic>.from(va), Map<String, dynamic>.from(vb))) return false;
      } else if (va != vb) return false;
    }
    return true;
  }

  void _readConfig() {
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    _style = Map<String, dynamic>.from(config['style'] as Map<String, dynamic>? ?? {});
    _chartOptions = Map<String, dynamic>.from(config['chartOptions'] as Map<String, dynamic>? ?? {});
    _readDataOnly();
  }

  void _readDataOnly() {
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final key = widget.field['key']?.toString() ?? '';

    Map<String, dynamic> d = {};

    if (config.containsKey('data') && config['data'] is Map<String, dynamic>) {
      d = Map<String, dynamic>.from(config['data']);
    } else if (widget.field.containsKey('data') && widget.field['data'] is Map<String, dynamic>) {
      d = Map<String, dynamic>.from(widget.field['data']);
    } else if (widget.manager.dataContext.containsKey(key) &&
        widget.manager.dataContext[key] is Map<String, dynamic>) {
      d = Map<String, dynamic>.from(widget.manager.dataContext[key]);
    } else if (widget.dataContext != null && widget.dataContext!.containsKey(key) && widget.dataContext![key] is Map) {
      d = Map<String, dynamic>.from(widget.dataContext![key]);
    } else {
      d = {};
    }

    _data = d;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = StyleParser.parseColor(_style['backgroundColor'], Colors.white);
    final height = StyleParser.parseDouble(_style['height'], 240.0);
    final padding = StyleParser.parseDouble(_style['padding'], 16.0);
    final margin = StyleParser.parseDouble(_style['margin'], 12.0);
    final borderRadius = StyleParser.parseDouble(_style['borderRadius'], 16.0);

    // chartOptions defaults
    final showLegend = _chartOptions['showLegend'] != false;
    final legendPosition = (_chartOptions['legendPosition'] ?? 'bottom').toString();
    final animationDuration = (_chartOptions['animationDuration'] is num)
        ? Duration(milliseconds: (_chartOptions['animationDuration'] as num).toInt())
        : const Duration(milliseconds: 600);

    final rawColors = _style['colors'] as Map<String, dynamic>? ?? {};
    final Map<String, Color> colorMap = {};
    rawColors.forEach((k, v) {
      colorMap[k.toLowerCase()] = StyleParser.parseColor(v, Colors.blue);
    });

    final chartData = _prepareChartData();
    final categories = chartData['categories'] as List<String>;

    // Enhanced Container/Card Style
    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15), // Softer shadow
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum space required
          children: [
            if ((widget.field['label'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  widget.field['label'],
                  style: TextStyle(
                    color: StyleParser.parseColor(_style['titleColor'], Colors.black87),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            // The chart is now wrapped in a SizedBox to ensure it respects the height constraint
            SizedBox(
              height: height, 
              child: StackedBarChart(
                data: chartData,
                colors: colorMap,
                chartOptions: _chartOptions,
                animationDuration: animationDuration,
              ),
            ),
            if (showLegend && categories.isNotEmpty)
              _buildLegend(categories, colorMap, legendPosition),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _prepareChartData() {
    final Map<String, dynamic> raw = _data.isNotEmpty ? _data : (widget.field['config']?['data'] ?? widget.field['data'] ?? {});
    final Map<String, dynamic> daily = Map<String, dynamic>.from(raw['dailyActivityHours'] ?? {});

    final Map<String, Map<String, double>> dayMap = {};

    for (final entryKey in daily.keys) {
      final val = daily[entryKey];
      if (val is Map) {
        final Map<String, double> map = {};
        val.forEach((k, v) {
          final numn = (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
          map[k.toString()] = numn;
        });
        dayMap[entryKey.toString()] = map;
      } else {
        dayMap[entryKey.toString()] = {};
      }
    }

    final labels = dayMap.keys.toList()
      ..sort((a, b) {
        final ai = int.tryParse(a) ?? 0;
        final bi = int.tryParse(b) ?? 0;
        return ai.compareTo(bi);
      });

    final Set<String> categories = {};
    for (final m in dayMap.values) {
      categories.addAll(m.keys);
    }
    final List<String> categoryList = categories.toList();

    final Map<String, List<double>> series = {};
    double maxVal = 0.0;
    for (final cat in categoryList) {
      series[cat] = [];
    }

    for (final lbl in labels) {
      final row = dayMap[lbl] ?? {};
      double stackSum = 0.0;
      for (final cat in categoryList) {
        final v = (row[cat] ?? 0.0).toDouble();
        series[cat]!.add(v);
        stackSum += v;
      }
      if (stackSum > maxVal) maxVal = stackSum;
    }

    if (maxVal > 0) {
        maxVal = (maxVal / 4.0).ceilToDouble() * 4.0;
        if (maxVal < 8.0) maxVal = 8.0; 
    } else {
        maxVal = 8.0;
    }

    return {
      'labels': labels,
      'series': series,
      'categories': categoryList,
      'maxValue': maxVal,
    };
  }

  Widget _buildLegend(List<String> categories, Map<String, Color> colorMap, String position) {
    final legendItems = categories.map((c) {
      final color = colorMap[c.toLowerCase()] ?? _defaultColorFor(c);
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(c, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        children: legendItems,
      ),
    );
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