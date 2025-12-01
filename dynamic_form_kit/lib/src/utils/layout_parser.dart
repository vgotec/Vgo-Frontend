import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/renderer/widget_factory.dart';
import 'package:flutter/material.dart';
import 'style_parser.dart';

class LayoutParser {
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext;

  LayoutParser({
    required this.manager,
    this.dataContext,
  });

  // ---------------------------------------------------------------------------
  // 🧱 Build all rows (content rows + footer rows)
  // ---------------------------------------------------------------------------
  List<Widget> buildRows(
    List<dynamic> rows,
    double rowSpacing, {
    Map<String, dynamic>? dataContext,
  }) {
    final List<Widget> builtRows = [];

    for (var row in rows) {
      builtRows.add(
        _buildRow(
          row as Map<String, dynamic>,
          dataContext: dataContext ?? this.dataContext,
        ),
      );

      // Add vertical spacing between rows
      if (row != rows.last) {
        builtRows.add(SizedBox(height: rowSpacing));
      }
    }

    return builtRows;
  }

  // ---------------------------------------------------------------------------
  // 🧱 Build a single row using layout types
  // ---------------------------------------------------------------------------
  Widget _buildRow(
    Map<String, dynamic> row, {
    Map<String, dynamic>? dataContext,
  }) {
    final String layoutType = row['layoutType'] ?? 'expanded';
    final List<dynamic> fields = row['fields'] ?? [];
    final double fieldGap = StyleParser.parseDouble(row['fieldGap'], 0.0);

    switch (layoutType) {
      case 'custom':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFields(
            fields,
            isFlex: true,
            fieldGap: fieldGap,
            dataContext: dataContext,
          ),
        );

      case 'alignment':
        final alignment = StyleParser.parseAlignment(row['alignment']);
        return Align(
          alignment: alignment,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildFields(
              fields,
              isFlex: false,
              fieldGap: fieldGap,
              dataContext: dataContext,
            ),
          ),
        );

      case 'expanded':
      default:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFields(
            fields,
            isFlex: true,
            fieldGap: fieldGap,
            dataContext: dataContext,
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 🧱 Build fields inside the row
  // ---------------------------------------------------------------------------
  List<Widget> _buildFields(
    List<dynamic> fields, {
    required bool isFlex,
    required double fieldGap,
    Map<String, dynamic>? dataContext,
  }) {
    final List<Widget> builtFields = [];

    for (int i = 0; i < fields.length; i++) {
      final Map<String, dynamic> fieldMap = fields[i] as Map<String, dynamic>;
      final config = fieldMap['config'] as Map<String, dynamic>? ?? {};
      final placement = config['placement'] as Map<String, dynamic>? ?? {};

      // -----------------------------------------------------------------------
      // ⭐ THE MOST IMPORTANT PART:
      // Pass BOTH manager and dataContext into WidgetFactory
      // so all widgets receive real-time updated values.
      // -----------------------------------------------------------------------
      final Widget child = WidgetFactory.buildWidget(
        fieldMap,
        manager,
        dataContext: dataContext ?? this.dataContext,
      );

      if (isFlex) {
        final int flex = (placement['flex'] ?? 1).toInt();
        builtFields.add(Expanded(flex: flex, child: child));
      } else {
        if (placement.containsKey('width')) {
          final double width = StyleParser.parseDouble(placement['width']);
          builtFields.add(SizedBox(width: width, child: child));
        } else {
          builtFields.add(child);
        }
      }

      // Add horizontal spacing between fields
      if (i < fields.length - 1) {
        builtFields.add(SizedBox(width: fieldGap));
      }
    }

    return builtFields;
  }
}
