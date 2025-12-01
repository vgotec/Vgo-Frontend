import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';

import 'package:timesheet_ui/data/model/leave_model.dart';
import 'package:timesheet_ui/data/services/activity_api_service.dart';

class LeaveFormPage extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic> formJson;
  final LeaveModel? initialData; // null = create, non-null = edit

  const LeaveFormPage({
    super.key,
    required this.selectedDate,
    required this.formJson,
    required this.initialData,
  });

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final FormStateManager _manager = FormStateManager();
  final ActivityApiService _apiService = ActivityApiService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------------
    // EDIT MODE → PRELOAD BACKEND VALUES
    // ------------------------------------------------------------------
    if (widget.initialData != null) {
      final map = widget.initialData!.toJson();

      // If backend provides nested "leave": {}
      if (map.containsKey("leave") && map["leave"] is Map) {
        map.addAll(map["leave"]);
      }

      _manager.updateDataContext(map);
    }

    _listenToActions();
  }

  // ---------------------------------------------------------------------------
  // 🔥 LISTEN TO JSON-DRIVEN BUTTON ACTIONS
  // ---------------------------------------------------------------------------
  void _listenToActions() {
    _manager.onAction.addListener(() async {
      final action = _manager.onAction.value;
      if (action == null) return;

      final type = action.type;
      final payload = action.payload ?? {};

      switch (type) {
        case "submit":
          await _handleSubmit(payload);
          break;

          case "delete":            // 👈 NEW
          await _handleDelete(payload);
          break;

        case "reset":
          _manager.reset();
          break;

        default:
          debugPrint("⚠ Unknown action in LeaveFormPage → $type");
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 📌 GENERIC SUBMIT HANDLER (CREATE OR UPDATE)
  // ---------------------------------------------------------------------------
  Future<void> _handleSubmit(Map<String, dynamic> payload) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final String? endpoint = payload["endpoint"];
      if (endpoint == null) {
        _showError("Submit endpoint missing from JSON");
        return;
      }

      final body = Map<String, dynamic>.from(_manager.formData);

      Map<String, dynamic> response;

      // CREATE MODE
      if (widget.initialData == null) {
        response = await _apiService.postJson(endpoint, body);
      }
      else {
        response = await _apiService.putJson(endpoint, body);
      }

      Navigator.pop(context, LeaveModel.fromMap(response));
    } catch (e) {
      _showError("Failed to submit leave: $e");
    }

    setState(() => _isLoading = false);
  }


    Future<void> _handleDelete(Map<String, dynamic> payload) async {
    if (_isLoading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Leave?"),
        content: const Text("Are you sure you want to delete this leave?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final endpoint = payload["endpoint"];
      if (endpoint == null) {
        _showError("Delete endpoint missing in JSON");
        return;
      }

      // JSON already contains full endpoint → no replacement needed
      await _apiService.deleteActivity(endpoint);

      Navigator.pop(context, "deleted");
    } catch (e) {
      _showError("Failed to delete leave: $e");
    }

    setState(() => _isLoading = false);
  }

  

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;
    final title = isEdit ? "Edit Leave" : "Apply Leave";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 23, 155),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          DynamicFormRenderer(
            formDefinition: widget.formJson,
            manager: _manager,
            hasScaffold: false,
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}
