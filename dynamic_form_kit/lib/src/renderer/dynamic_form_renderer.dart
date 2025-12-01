
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
import 'package:flutter/material.dart';
import '../utils/layout_parser.dart';
import '../utils/style_parser.dart';

class DynamicFormRenderer extends StatefulWidget {
  final Map<String, dynamic> formDefinition;
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext;

  /// wrap in its own Scaffold or not
  final bool hasScaffold;

  const DynamicFormRenderer({
    super.key,
    required this.formDefinition,
    required this.manager,
    this.dataContext,
    this.hasScaffold = true,
  });

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _applyJsonDefaults();
  }

  // ---------------------------------------------------------------------------
  // ⭐ APPLY DEFAULT VALUE LOGIC (GENERIC)
  // ---------------------------------------------------------------------------
  void _applyJsonDefaults() {
    try {
      final layout = widget.formDefinition['layout'] as Map<String, dynamic>? ?? {};
      final rows = layout['rows'] as List<dynamic>? ?? [];

      for (var r in rows) {
        final row = r as Map<String, dynamic>;
        final fields = (row['fields'] as List<dynamic>?) ?? [];

        for (var f in fields) {
          final field = f as Map<String, dynamic>;
          final key = field['key']?.toString();
          if (key == null || key.isEmpty) continue;

          // Skip if already has backend value
          final existing = widget.manager.getValue(key);
          if (existing != null && existing.toString().isNotEmpty) continue;

          dynamic defaultVal;

          // 🔥 priority #1: root level defaultValue
          defaultVal = field['defaultValue'];

          final config = field['config'] as Map<String, dynamic>? ?? {};
          final dataConfig = config['data'] as Map<String, dynamic>? ?? {};

          // 🔥 priority #2: config.data.default
          defaultVal ??= dataConfig['default'];

          // 🔥 priority #3: config.defaultValue
          defaultVal ??= config['defaultValue'];

          if (defaultVal != null) {
            widget.manager.setFieldValue(key, _parseDefault(defaultVal));
          }
        }
      }

      setState(() => _initialized = true);
    } catch (e) {
      debugPrint("⚠ DynamicFormRenderer _applyJsonDefaults(): $e");
      _initialized = true;
    }
  }

  dynamic _parseDefault(dynamic val) {
    if (val == null) return null;
    final lower = val.toString().toLowerCase();

    if (lower == "today") {
      return DateTime.now().toIso8601String().split("T").first;
    }
    if (lower == "now") {
      return DateTime.now().toIso8601String();
    }
    return val;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final formConfig = widget.formDefinition['formConfig'] as Map<String, dynamic>? ?? {};
    final bgColor = StyleParser.parseColor(formConfig['backgroundColor'], Colors.white);
    final padding = StyleParser.parseDouble(formConfig['padding'], 16.0);
    final rowSpacing = StyleParser.parseDouble(formConfig['rowSpacing'], 12.0);

    final layout = widget.formDefinition['layout'] as Map<String, dynamic>? ?? {};
    final rows = layout['rows'] as List<dynamic>? ?? [];

    final contentRows = rows.where((r) => r['isFooter'] != true).toList();
    final footerRows = rows.where((r) => r['isFooter'] == true).toList();

    final layoutParser = LayoutParser(
      manager: widget.manager,
      dataContext: widget.manager.dataContext,
    );

    Widget body = Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: layoutParser.buildRows(
                  contentRows,
                  rowSpacing,
                  dataContext: widget.manager.dataContext,
                ),
              ),
            ),
          ),
          if (footerRows.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: Column(
                children: layoutParser.buildRows(
                  footerRows,
                  rowSpacing,
                  dataContext: widget.manager.dataContext,
                ),
              ),
            ),
        ],
      ),
    );

    if (!widget.hasScaffold) {
      return body;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: body,
    );
  }
}
