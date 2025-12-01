import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
import 'package:timesheet_ui/data/model/activity_form_model.dart';
import 'package:timesheet_ui/data/services/activity_api_service.dart';

class ActivityFormPage extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic> formJson;
  
  // ⭐️ 1. ADD initialData (make it nullable)
  final ActivityFormModel? initialData; 

  const ActivityFormPage({
    Key? key,
    required this.selectedDate,
    required this.formJson,
    this.initialData,
  }) : super(key: key);

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  late FormStateManager manager;
  final ActivityApiService _apiService = ActivityApiService();
  String? _submitEndpoint;
  bool _isSubmitting = false;

// In ActivityFormPage.dart

  @override
// In ActivityFormPage.dart

  @override
  void initState() {
    super.initState();
    
    // 1. Create the manager (it's empty for now)
    manager = FormStateManager(); 
    
    // 2. Set up listeners
    manager.onAction.addListener(_handleFormAction);
    _findSubmitEndpoint();

    // 3. Pre-populate the form AFTER the first frame is built
    if (widget.initialData != null) {
      // This schedules _prepopulateForm to run right after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure the widget is still in the tree
          _prepopulateForm();
        }
      });
    }
  }

  /// Finds the 'submit' action in the form JSON and stores its endpoint.
  void _findSubmitEndpoint() {
    try {
      final List<dynamic> rows = widget.formJson['layout']?['rows'] ?? [];
      for (var row in rows) {
        final List<dynamic> fields = row['fields'] ?? [];
        for (var field in fields) {
          final action = field['action'] as Map<String, dynamic>?;
          if (field['type'] == 'button' && action?['type'] == 'submit') {
            final Map<String, dynamic>? payload = action?['payload'];
            _submitEndpoint = payload?['endpoint'];
            if (_submitEndpoint != null) {
              debugPrint("✅ Submit/Update endpoint found: $_submitEndpoint");
              return;
            }
          }
        }
      }
      debugPrint("⚠️ No 'submit' action with an 'endpoint' found in its 'payload'.");
    } catch (e) {
      debugPrint("❌ Error parsing JSON for submit endpoint: $e");
    }
  }
  
// In ActivityFormPage.dart

  // ⭐️ REPLACE your old _prepopulateForm with this ⭐️
void _prepopulateForm() {
    // 1. Get the raw JSON data
    final Map<String, dynamic> formData =
        Map<String, dynamic>.from(widget.initialData!.toJson());

    debugPrint("Pre-populating form with data: $formData");

    // 2. REMOVE READ-ONLY & COMPUTED FIELDS
    formData.remove('workHours');
    formData.remove('workDate'); // This field doesn't exist on the model

    try {
      // 3. Get the base date from the WIDGET, not the model
      final DateTime baseDate = widget.selectedDate; // ⭐️ THE FIX IS HERE

      // 4. SAFELY convert startTime to a full DateTime
      if (formData['startTime'] is String &&
          (formData['startTime'] as String).isNotEmpty) {
        final timeParts = (formData['startTime'] as String).split(':');
        formData['startTime'] = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
        );
      }

      // 5. SAFELY convert endTime to a full DateTime
      if (formData['endTime'] is String &&
          (formData['endTime'] as String).isNotEmpty) {
        final timeParts = (formData['endTime'] as String).split(':');
        formData['endTime'] = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
        );
      }
    } catch (e) {
      debugPrint("⚠️ Error converting time strings to DateTime: $e.");
      formData['startTime'] = null;
      formData['endTime'] = null;
    }

    // 6. Update the manager with the cleaned data
    debugPrint("Populating manager with cleaned data: $formData");
    manager.updateDataContext(formData);
  }
  @override
  void dispose() {
    manager.onAction.removeListener(_handleFormAction);
    manager.dispose();
    super.dispose();
  }

  /// Handles "submit" and "reset" button actions
  void _handleFormAction() {
    final action = manager.onAction.value;
    if (action == null) return;
    
    final String actionType = action.type;
    debugPrint("➡️ ACTION RECEIVED: $actionType");

    switch (actionType) {
      case 'submit':
        _handleSubmit();
        break;
      case 'reset':
         // In edit mode, reset to initial data. In create mode, clear.
        widget.initialData != null ? _prepopulateForm() : manager.reset();
        break;
      default:
        debugPrint("Unknown action: $actionType");
    }
  }

  /// Handles submit button logic (for both CREATE and UPDATE)
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (_submitEndpoint == null) {
      _showError("Error: Submit endpoint not configured in JSON payload.");
      return;
    }
    
    setState(() { _isSubmitting = true; });

    final formData = Map<String, dynamic>.from(manager.formData);
    // Add/override the WorkDate
    formData['WorkDate'] = widget.selectedDate.toIso8601String().split("T")[0];

    // ⭐️ 4. If in "Edit" mode, make sure the ID is included
    if (widget.initialData != null) {
      formData['id'] = widget.initialData!.id;
    }

    debugPrint("📝 Form data to submit: $formData");

    try {
      final formModel = ActivityFormModel.fromMap(formData);
      
      // ⭐️ 5. Use the SAME saveActivity method. It's now generic.
      // The endpoint from JSON will be different for "Create" vs "Update".
      final ActivityFormModel savedActivity;

      if (widget.initialData != null) {
        // We are in EDIT mode, call the new update method
        debugPrint("Calling updateActivity...");
        savedActivity = await _apiService.updateActivity(
          form: formModel,
          endpoint: _submitEndpoint!,
          date: widget.selectedDate,
        );
      } else {
        // We are in CREATE mode, call the existing save method
        debugPrint("Calling saveActivity...");
        savedActivity = await _apiService.saveActivity(
          form: formModel,
          endpoint: _submitEndpoint!,
          date: widget.selectedDate,
        );
      }

      _showSuccess(
        widget.initialData != null ? "Activity updated!" : "Activity saved!"
      );

      if (mounted) {
         Navigator.of(context).pop(savedActivity); // Return the saved/updated activity
      }
     
    } catch (e, stack) {
      _showError("Failed to save: $e");
      debugPrint("❌ API save failed: $e\n$stack");
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }
  
  // --- Helper Methods ---
  
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // --- build() ---
  
  @override
  Widget build(BuildContext context) {
    // ⭐️ 6. Update title based on mode
    final isEditMode = widget.initialData != null;
    final formJson = widget.formJson;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Activity" : (formJson['title'] ?? "Log New Activity"),
        style: const TextStyle(
            color: Colors.white,
          )),
        
        backgroundColor: const Color(0xFF06179B),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DynamicFormRenderer(
              formDefinition: formJson,
              manager: manager,
            ),
          ),
          
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}