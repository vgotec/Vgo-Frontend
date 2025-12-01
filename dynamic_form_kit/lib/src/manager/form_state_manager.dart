import 'package:flutter/material.dart';

/// Represents a user action like "submit" or "reset"
class FormAction {
  final String type;
  final Map<String, dynamic>? payload;
  FormAction(this.type, {this.payload});
}

class FormStateManager with ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 🧩 CORE FORM STATE
  // ---------------------------------------------------------------------------
  final Map<String, dynamic> _data = {};                         // actual values
  final Map<String, TextEditingController> _controllers = {};    // text inputs
  final Map<String, List<Map<String, String>>> _dropdownData = {}; // dropdown meta

  // ---------------------------------------------------------------------------
  // 🧩 DATA CONTEXT (backend → widgets)
  // ---------------------------------------------------------------------------
  Map<String, dynamic> _dataContext = {};
  Map<String, dynamic> get dataContext => _dataContext;

  /// Clears context entirely
  void clearDataContext() {
    _dataContext.clear();
    debugPrint("🧩 dataContext cleared.");
    notifyListeners();
  }

  /// Replace entire data context (edit mode or backend-injected values)
  void updateDataContext(Map<String, dynamic> newData) {
    _dataContext = Map<String, dynamic>.from(newData);

    debugPrint("🧩 dataContext updated: $_dataContext");

    // ⭐ AUTO-POPULATE FORM FIELDS FROM CONTEXT (GENERIC PREFILL)
    newData.forEach((key, value) {
      if (value == null) return;

      // If controller exists → set text
      if (_controllers.containsKey(key)) {
        _controllers[key]!.text = value.toString();
      }

      // Store value inside manager
      _data[key] = value;
    });

    notifyListeners();
  }

  // Update only a single table/list in context (dynamic tables)
  void refreshTableData(String key, List<Map<String, dynamic>> newRows) {
    _dataContext[key] = newRows;
    debugPrint("🔁 Table data refreshed for [$key]");
    notifyListeners();
  }

  void logDataContext() {
    debugPrint("🧩 Current dataContext: $_dataContext");
  }

  // ---------------------------------------------------------------------------
  // 🧩 ACTION DISPATCH SYSTEM
  // ---------------------------------------------------------------------------
  final ValueNotifier<FormAction?> _actionNotifier = ValueNotifier(null);
  ValueNotifier<FormAction?> get onAction => _actionNotifier;

  void dispatchAction(String type, {Map<String, dynamic>? payload}) {
    _actionNotifier.value = FormAction(type, payload: payload);
    Future.delayed(Duration.zero, () => _actionNotifier.value = null);
  }

  void triggerAction(Map<String, dynamic> config) {
    final type = config['type']?.toString() ?? 'unknown';
    final payload = (config['payload'] is Map)
        ? Map<String, dynamic>.from(config['payload'])
        : null;

    dispatchAction(type, payload: payload);
  }

  // ---------------------------------------------------------------------------
  // 🧩 FIELD REGISTRATION
  // ---------------------------------------------------------------------------
  TextEditingController registerTextField(String key) {
    if (_controllers.containsKey(key)) return _controllers[key]!;

    final controller = TextEditingController();

    _controllers[key] = controller;
    _data[key] = controller.text;

    // Text change updates manager
    controller.addListener(() {
      _data[key] = controller.text;
      notifyListeners();
    });

    return controller;
  }

  /// Generic setter for any widget
  void setFieldValue(String key, dynamic value) {
    _data[key] = value;

    if (_controllers.containsKey(key)) {
      if (_controllers[key]!.text != value.toString()) {
        _controllers[key]!.text = value.toString();
      }
    }

    notifyListeners();
  }

  /// Dropdown item registration
  void registerDropdownData(String key, List<Map<String, String>> items) {
    _dropdownData[key] = items;
  }

  dynamic getValue(String key) => _data[key];

  Map<String, dynamic> get formData => Map.unmodifiable(_data);

  // ---------------------------------------------------------------------------
  // 🧩 RESET FORM
  // ---------------------------------------------------------------------------
  void reset() {
    _data.clear();
    for (var controller in _controllers.values) {
      controller.clear();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🧩 LINKED FIELDS (Dropdown → Text)
  // ---------------------------------------------------------------------------
  void syncLinkedFields(
    String key,
    dynamic newValue,
    Map<String, dynamic> field,
  ) {
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final data = config['data'] as Map<String, dynamic>? ?? {};
    final links = data['links'] as List<dynamic>? ?? [];

    // Human readable label from dropdown
    final label = _dropdownData[key]
        ?.firstWhere(
          (item) => item['value'] == newValue.toString(),
          orElse: () => {'label': newValue.toString()},
        )['label'];

    for (final linkKey in links) {
      if (linkKey is String) {
        _data[linkKey] = label;
        if (_controllers.containsKey(linkKey)) {
          _controllers[linkKey]!.text = label!;
        }
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _actionNotifier.dispose();
    super.dispose();
  }
}
