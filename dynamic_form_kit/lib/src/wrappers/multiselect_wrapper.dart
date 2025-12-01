// lib/presentation/widgets/dynamic_form/wrappers/multiselect_wrapper.dart


import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_multiselect.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; 
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';

// 1. Changed to StatelessWidget
class MultiSelectWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const MultiSelectWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  // 2. Removed the _fetchAndParseData method.
  //    The screen is now responsible for fetching data and
  //    providing it in the 'options' list.

  @override
  Widget build(BuildContext context) {
    final String key = field['key'] as String;
    final String label = field['label'] ?? '';
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final data = config['data'] as Map<String, dynamic>? ?? {};
    final dataSource = data['dataSource'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};
    final text = config['text'] as Map<String, dynamic>? ?? {};
    final behavior = config['behavior'] as Map<String, dynamic>? ?? {};

    // --- Parse Config ---
    final String placeholder = text['placeholder'] ?? 'Select...';
    final String dialogTitle = text['dialogTitle'] ?? label;
    final String searchHint = text['searchHint'] ?? 'Search...';
    final bool searchable = behavior['searchable'] ?? false;
    
    // --- Parse Styles ---
    final Color chipBgColor = StyleParser.parseColor(style['chipBackgroundColor'], Colors.blue.shade100);
    final Color chipTextColor = StyleParser.parseColor(style['chipTextColor'], Colors.blue.shade900);
    final Color borderColor = StyleParser.parseColor(style['borderColor'], Colors.grey.shade400);

    // --- Data Parsing (Now Simple) ---
    // We read from 'options', which the screen is expected to provide.
    final options = data['options'] as List<dynamic>? ?? [];
    final String valueField = dataSource['valueField'] ?? 'value';
    final String displayField = dataSource['displayField'] ?? 'label';
    
    List<Map<String, String>> parsedItems = [];
    for (var option in options) {
      if (option is Map) {
        parsedItems.add({
          "label": option[displayField]?.toString() ?? '',
          "value": option[valueField]?.toString() ?? '',
        });
      }
    }

    // Convert the loaded {label, value} maps into MultiSelectItem
    final List<MultiSelectItem<String>> multiSelectItems = parsedItems
        .map((item) => MultiSelectItem<String>(item['value']!, item['label']!))
        .toList();
        
    // 3. Get the current value directly from the manager
    //    We cast it to be safe.
    final List<String> currentSelectedValues = 
        (manager.getValue(key) as List<dynamic>?)?.cast<String>() ?? [];

    // 4. Removed the FutureBuilder. The widget builds immediately.
    return VgotecMultiSelect(
      label: label,
      placeholder: placeholder,
      dialogTitle: dialogTitle,
      searchHint: searchHint,
      items: multiSelectItems,
      initialValue: currentSelectedValues, // Use the value from the manager
      searchable: searchable,
      chipBackgroundColor: chipBgColor,
      chipTextColor: chipTextColor,
      borderColor: borderColor,
      onConfirm: (List<String> results) {
        // 5. Save the value back to the manager.
        //    This will trigger notifyListeners() inside the manager.
        manager.setFieldValue(key, results);
      },
    );
  }
}