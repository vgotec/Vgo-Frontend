import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const DateWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  _DateWrapperState createState() => _DateWrapperState();
}

class _DateWrapperState extends State<DateWrapper> {
  String? _displayDate;

  @override
  void initState() {
    super.initState();

    final key = widget.field['key'];
    final dynamic defaultValue = widget.field['defaultValue'];

    // 1️⃣ EDIT MODE (existing value from manager)
    final existing = widget.manager.getValue(key);
    if (existing != null) {
      final parsed = DateTime.tryParse(existing);
      if (parsed != null) {
        _displayDate = DateFormat('MMM dd, yyyy').format(parsed);
      }
      return;
    }

    // 2️⃣ CREATE MODE (default value)
    if (defaultValue != null) {
      final parsed = _parseDefault(defaultValue);
      if (parsed != null) {
        widget.manager.setFieldValue(key, parsed.toIso8601String());
        _displayDate = DateFormat('MMM dd, yyyy').format(parsed);
      }
    }
  }

  DateTime? _parseDefault(dynamic value) {
    if (value == "today") return DateTime.now();
    if (value == "now") return DateTime.now();

    return DateTime.tryParse(value.toString());
  }

  Future<void> _selectDate(String key) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      widget.manager.setFieldValue(key, picked.toIso8601String());
      setState(() {
        _displayDate = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.field['key'];
    final label = widget.field['label'] ?? "";

    final config = widget.field['config'] ?? {};
    final style = config['style'] ?? {};
    final text = config['text'] ?? {};
    final behavior = config['behavior'] ?? {};
    final bool isRequired = behavior['required'] ?? false;
    final bool readOnly = behavior['readOnly'] == true;

    final String placeholder = text['placeholder'] ?? "Select date";

    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);
    final Color iconColor =
        StyleParser.parseColor(style['iconColor'], Colors.blue);

    return VgotecDatePicker(
      label: label,
      placeholder: placeholder,
      value: _displayDate,
      isRequired: isRequired,
      labelColor: labelColor,
      iconColor: iconColor,
      readOnly: readOnly,
      onTap: readOnly ? null : () => _selectDate(key),
    );
  }
}
