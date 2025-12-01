import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/renderer/dynamic_form_renderer.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:timesheet_ui/data/services/activity_api_service.dart';

class DashboardFormScreen extends StatefulWidget {
  final String formEndpoint; // 🔥 Now endpoint instead of asset path

  const DashboardFormScreen({
    super.key,
    required this.formEndpoint,
  });

  @override
  State<DashboardFormScreen> createState() => _DashboardFormScreenState();
}

class _DashboardFormScreenState extends State<DashboardFormScreen> {
  Map<String, dynamic>? formDefinition;

  final manager = FormStateManager();
  final ActivityApiService _apiService = ActivityApiService();

  @override
  void initState() {
    super.initState();
    _loadFormFromApi();
  }

  Future<void> _loadFormFromApi() async {
    try {
      final Map<String, dynamic> jsonData =
          await _apiService.getFormDefinition(widget.formEndpoint);

      setState(() {
        formDefinition = jsonData;
      });
    } catch (e) {
      print("❌ Failed to load dashboard JSON: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error loading dashboard configuration")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (formDefinition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DynamicFormRenderer(
      formDefinition: formDefinition!,
      manager: manager,
      hasScaffold: false,
    );
  }
}
