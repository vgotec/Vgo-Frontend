import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:dynamic_form_kit/src/widget_collection/productivity_gauge.dart';
import '../manager/form_state_manager.dart';
import '../utils/style_parser.dart';


/// Wrapper that adapts your JSON field into the ProductivityGauge widget.
class GaugeWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext;

  const GaugeWrapper({
    Key? key,
    required this.field,
    required this.manager,
    this.dataContext,
  }) : super(key: key);

  @override
  _GaugeWrapperState createState() => _GaugeWrapperState();
}

class _GaugeWrapperState extends State<GaugeWrapper> {
  Map<String, dynamic> _style = {};
  Map<String, dynamic> _chartOptions = {};
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _readConfig();
    widget.manager.addListener(_onManagerChange);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChange);
    super.dispose();
  }

  void _onManagerChange() {
    final old = _data;
    _readDataOnly();
    if (old.toString() != _data.toString()) { // Simple check for maps/primitives
      setState(() {});
    }
  }

  void _readConfig() {
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    _style = Map<String, dynamic>.from(config['style'] as Map<String, dynamic>? ?? {});
    _chartOptions = Map<String, dynamic>.from(config['chartOptions'] as Map<String, dynamic>? ?? {});
    _readDataOnly();
  }

  void _readDataOnly() {
    // Priority: field.config.data -> field.data -> manager.dataContext[field.key] -> widget.dataContext[field.key]
    final key = widget.field['key']?.toString() ?? '';
    Map<String, dynamic> d = {};

    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    
    // Check if 'config' contains a 'data' map
    if (config.containsKey('data') && config['data'] is Map<String, dynamic>) {
      _data = Map<String, dynamic>.from(config['data']);
      return; // Data found, stop here
    } else if (widget.manager.dataContext.containsKey(key) &&
        widget.manager.dataContext[key] is Map<String, dynamic>) {
      d = Map<String, dynamic>.from(widget.manager.dataContext[key]);
    } else if (widget.dataContext != null && widget.dataContext!.containsKey(key) && widget.dataContext![key] is Map) {
      d = Map<String, dynamic>.from(widget.dataContext![key]);
    } else {
      d = {};
    }
    
    // Fallback to the provided JSON example if no other data context is found
    if (d.isEmpty && widget.field['dataKey'] == 'productivity') {
       d = const { 
          "workingDays" : 20, "totalHoursWorked" : 10.0, 
          "expectedHours" : 160.0, "productivityPercentage" : 6.25, 
          "category" : "LOW"
       };
    }
    _data = d;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = StyleParser.parseColor(_style['backgroundColor'], Colors.white);
    final height = StyleParser.parseDouble(_style['height'], 260.0);
    final padding = StyleParser.parseDouble(_style['padding'], 16.0);
    final margin = StyleParser.parseDouble(_style['margin'], 12.0);
    final borderRadius = StyleParser.parseDouble(_style['borderRadius'], 16.0);

    final title = widget.field['title']?.toString() ?? 'Gauge Chart';
    final value = (_data['productivityPercentage'] ?? 0.0).toDouble();

    // Map JSON rangeColors (Hex or String) to Flutter Color objects
    final rangeColors = List<String>.from(_chartOptions['rangeColors'] ?? []);
    final List<Color> colors = rangeColors.map((hex) => StyleParser.parseColor(hex, Colors.grey)).toList();

    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: StyleParser.parseColor(_style['titleColor'], Colors.black87),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: height - 40, // Reduced height for title/padding
              child: ProductivityGauge(
                value: value,
                min: 0,
                max: 100, // Productivity is typically a percentage
                rangeColors: colors,
                chartOptions: _chartOptions,
                data: _data,
              ),
            ),
          ],
        ),
      ),
    );
  }
}