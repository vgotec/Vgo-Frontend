import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';

class DetailsViewWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext;

  const DetailsViewWrapper({
    super.key,
    required this.field,
    required this.manager,
    this.dataContext,
  });

  @override
  Widget build(BuildContext context) {
    final config = field['config'] ?? {};
    final columns = config['columns'] ?? 2;

    final style = config['style'] ?? {};
    final labelColor = StyleParser.parseColor(style['labelColor'], Colors.black87);
    final valueColor = StyleParser.parseColor(style['valueColor'], Colors.black);
    final fontSize = StyleParser.parseDouble(style['fontSize'], 14);
    final labelWeight = StyleParser.parseFontWeight(style['labelWeight']);
    final gap = StyleParser.parseDouble(style['gap'], 8);

    final dataMap = config['dataMap'] ?? {};

    final ctx = dataContext ?? manager.dataContext;

    final List<Widget> rows = [];

    dataMap.forEach((label, key) {
      final value = ctx[key]?.toString() ?? "-";

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: labelWeight,
                    color: labelColor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: rows,
      ),
    );
  }
}
