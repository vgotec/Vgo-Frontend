// lib/presentation/widgets/dynamic_form/wrappers/phase_editor_wrapper.dart

import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_phase_editor.dart';
import 'package:flutter/material.dart';


class PhaseEditorWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const PhaseEditorWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  _PhaseEditorWrapperState createState() => _PhaseEditorWrapperState();
}

class _PhaseEditorWrapperState extends State<PhaseEditorWrapper> {
  final _phaseController = TextEditingController();
  
  // State for this widget
  List<String> _projectPhases = [];
  List<String> _removedPhases = [];
  List<String> _defaultPhases = [];

  @override
  void initState() {
    super.initState();
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final data = config['data'] as Map<String, dynamic>? ?? {};

    // 1. Load default values from JSON
    _defaultPhases = List<String>.from(data['defaultValues'] ?? []);
    
    // 2. Initialize the list with these defaults
    _projectPhases = List<String>.from(_defaultPhases);
    
    // 3. Save this initial state to the manager
    _updateManager();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
  }

  void _updateManager() {
    // Save the current list of phases to the FormStateManager
    widget.manager.setFieldValue(widget.field['key'] as String, _projectPhases);
  }

  // --- All state logic lives here in the wrapper ---
  void _addCustomPhase() {
    final name = _phaseController.text.trim();
    if (name.isNotEmpty && !_projectPhases.contains(name)) {
      setState(() {
        _projectPhases.add(name);
        _removedPhases.remove(name);
        _phaseController.clear();
      });
      FocusScope.of(context).unfocus();
      _updateManager();
    }
  }

  void _removePhase(String phaseName) {
    setState(() {
      _projectPhases.remove(phaseName);
      if (_defaultPhases.contains(phaseName)) {
        _removedPhases.add(phaseName);
      }
    });
    _updateManager();
  }
  
  void _reAddPhase(String phaseName) {
    setState(() {
      _removedPhases.remove(phaseName);
      _projectPhases.add(phaseName);
    });
    _updateManager();
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final String item = _projectPhases.removeAt(oldIndex);
      _projectPhases.insert(newIndex, item);
    });
    _updateManager();
  }
  // --- End state logic ---

  @override
  Widget build(BuildContext context) {
    // Parse all config values
    final String label = widget.field['label'] ?? '';
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};
    final placement = config['placement'] as Map<String, dynamic>? ?? {};
    final behavior = config['behavior'] as Map<String, dynamic>? ?? {};
    final text = config['text'] as Map<String, dynamic>? ?? {};

    // 4. Call the "dumb" skeleton widget and pass all
    // state, callbacks, and parsed styles to it.
    return VgotecPhaseEditor(
      // State
      currentPhases: _projectPhases,
      removedPhases: _removedPhases,
      textController: _phaseController,
      
      // Callbacks
      onAddPhase: _addCustomPhase,
      onRemovePhase: _removePhase,
      onReAddPhase: _reAddPhase,
      onReorder: _onReorder,
      
      // Text
      label: label,
      addPhaseLabel: text['addPhaseLabel'] ?? 'Add Custom Phase',
      
      // Behavior
      listShrinkWrap: behavior['listShrinkWrap'] ?? true,
      listPhysics: StyleParser.parseScrollPhysics(behavior['listPhysics']),
      showDragHandle: behavior['showDragHandle'] ?? true,
      showDeleteIcon: behavior['showDeleteIcon'] ?? true,
      
      // Placement
      labelPaddingBottom: StyleParser.parseDouble(placement['labelPaddingBottom'], 12.0),
      maxHeight: StyleParser.parseDouble(placement['maxHeight'], 250.0),
      listPadding: StyleParser.parseDouble(placement['listPadding'], 8.0),
      cardMarginVertical: StyleParser.parseDouble(placement['cardMarginVertical'], 4.0),
      cardElevation: StyleParser.parseDouble(placement['cardElevation'], 1.0),
      removedPillSpacing: StyleParser.parseDouble(placement['removedPillSpacing'], 8.0),
      removedPillRunSpacing: StyleParser.parseDouble(placement['removedPillRunSpacing'], 4.0),
      
      // Style
      labelColor: StyleParser.parseColor(style['labelColor'], Colors.black),
      pillBackgroundColor: StyleParser.parseColor(style['pillBackgroundColor'], Colors.blue.shade100),
      pillTextColor: StyleParser.parseColor(style['pillTextColor'], Colors.blue.shade900),
      pillIconColor: StyleParser.parseColor(style['pillIconColor'], Colors.green),
      dragHandleColor: StyleParser.parseColor(style['dragHandleColor'], Colors.grey),
      deleteIconColor: StyleParser.parseColor(style['deleteIconColor'], Colors.red),
      addIconColor: StyleParser.parseColor(style['addIconColor'], Colors.blue),
    );
  }
}