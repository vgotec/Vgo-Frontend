import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_table.dart';

class VgotecTableWrapper extends StatelessWidget {
  final Map<String, dynamic> config;
  final FormStateManager manager;
  final Function(List<Map<String, dynamic>>) onChanged;

  const VgotecTableWrapper({
    Key? key,
    required this.config,
    required this.manager,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = config['label']?.toString() ?? '';
    final columns =
        (config['columns'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final style = config['style'] as Map<String, dynamic>? ?? {};
   

    // ✅ Use a stable data key — required for dataContext
    final dataKey = config['dataKey'] ??
        label.toLowerCase().replaceAll(' ', '_');

    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        // ✅ Always pull live table data from FormStateManager
        List<Map<String, dynamic>> rows = [];

        final dynamic liveData = manager.dataContext[dataKey];
        if (liveData is List) {
          rows = List<Map<String, dynamic>>.from(liveData);
        } else if (config["rows"] is List && liveData == null) {
          // fallback: static rows from JSON
          rows = List<Map<String, dynamic>>.from(config["rows"]);
        }

        return VgotecTable(
          dataKey: dataKey,
          label: label,
          columns: columns,
          rows: rows,
          borderColor:
              StyleParser.parseColor(style['borderColor'], Colors.grey),
          headerColor: StyleParser.parseColor(
              style['headerColor'], Colors.grey.shade300),
          textColor:
              StyleParser.parseColor(style['textColor'], Colors.black),
          borderWidth: StyleParser.parseDouble(style['borderWidth'], 1.0),

          // ✅ When table changes (edit/delete), update global context
          onChanged: (updatedRows) {
            manager.refreshTableData(dataKey, updatedRows);
            onChanged(updatedRows);
          },

          manager: manager,
        );
      },
    );
  }
}
