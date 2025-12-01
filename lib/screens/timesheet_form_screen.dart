import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:convert';

// 📦 Dynamic Form Kit
import 'package:dynamic_form_kit/dynamic_form_kit.dart';

// 📱 Timesheet UI
import 'package:timesheet_ui/screens/ActivityFormPage.dart';
import 'package:timesheet_ui/data/model/activity_form_model.dart';
import 'package:timesheet_ui/data/model/timesheet_data_model.dart';
import 'package:timesheet_ui/data/services/activity_api_service.dart';

class TimesheetFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final FormStateManager manager;
  final TimesheetDataModel initialData;

  const TimesheetFormScreen({
    super.key,
    required this.selectedDate,
    required this.manager,
    required this.initialData,
  });

  @override
  State<TimesheetFormScreen> createState() => _TimesheetFormScreenState();
}

class _TimesheetFormScreenState extends State<TimesheetFormScreen> {
  late List<ActivityFormModel> _sessionActivities;
  final ActivityApiService _apiService = ActivityApiService();
  bool _isLoading = false;

  // ⭐️ 1. ADD A LOCAL STATE VARIABLE FOR STATUS
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _sessionActivities = List.from(widget.initialData.entries);

    // ⭐️ 2. INITIALIZE THE LOCAL STATUS
    _currentStatus = widget.initialData.status;

    _populateManager();
    _listenToActions();
  }

  void _populateManager() {
    // Update the manager with all the data from the model
    widget.manager.updateDataContext({
      "activities": _sessionActivities.map((e) => e.toJson()).toList(),

      // ⭐️ 3. USE THE LOCAL _currentStatus
      "timesheetStatus": _currentStatus,

      "totalHours": widget.initialData.totalHours,
    });

    // Trigger a rebuild
    setState(() {});
  }

  void _listenToActions() {
    widget.manager.onAction.addListener(() async {
      final action = widget.manager.onAction.value;
      if (action == null) return;

      final String actionType = action.type;
      final Map<String, dynamic> payload = action.payload ?? const {};

      debugPrint(
        "TimesheetFormScreen: Received actionType='$actionType', payload='$payload'",
      );

      switch (actionType) {
        case 'add_new':
          await _handleAddNewAction(payload);
          break;

        case 'submit':
          await _handleSubmitTimesheet(payload);
          break;

        case 'delete_timesheet':
          await _handleDeleteTimesheet(payload);
          break;

        case 'delete_row':
          await _handleDeleteRowAction(payload);
          break;
        case 'edit_row':
          await _handleEditRowAction(payload);
          break;
      }
    });
  }

  // ... _handleAddNewAction remains the same ...
  Future<void> _handleAddNewAction(Map<String, dynamic> payload) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final String? endpoint = payload['endpoint'];
    if (endpoint == null) {
      _showError("Error: 'Add New' endpoint not configured.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final Map<String, dynamic> newFormJson = await _apiService
          .getFormDefinition(endpoint);
      final newActivity = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityFormPage(
            selectedDate: widget.selectedDate,
            formJson: newFormJson,
            initialData: null,
          ),
        ),
      );

      if (newActivity != null && newActivity is ActivityFormModel) {
        _sessionActivities.add(newActivity);
        _populateManager();
        debugPrint("✅ New activity added and manager refreshed.");
      }
    } catch (e) {
      _showError("Error loading form: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmitTimesheet(Map<String, dynamic> payload) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String? endpoint = payload['endpoint'];
    if (endpoint == null) {
      _showError("Error: 'Submit' endpoint not configured.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final String timesheetId = widget.initialData.id;
      endpoint = endpoint.replaceAll('{id}', timesheetId);
      final Map<String, dynamic> body = {"status": "SUBMITTED"};

      await _apiService.submitTimesheetStatus(endpoint, body);

      _showSuccess("Timesheet submitted successfully!");

      // ⭐️ 4. UPDATE THE LOCAL _currentStatus (THIS IS THE FIX)
      _currentStatus = "SUBMITTED";

      // Re-populate the manager with the new status
      _populateManager();
    } catch (e) {
      _showError("Error submitting timesheet: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ... _handleDeleteTimesheet remains the same ...
  Future<void> _handleDeleteTimesheet(Map<String, dynamic> payload) async {
    if (_isLoading) return;

    final bool didConfirm = await _showDeleteConfirmation(
      "Delete Timesheet?",
      "Are you sure you want to delete this entire timesheet? This action cannot be undone.",
    );
    if (!didConfirm || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    String? endpoint = payload['endpoint'];
    if (endpoint == null) {
      _showError("Error: 'Delete' endpoint not configured.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final String timesheetId = widget.initialData.id;
      endpoint = endpoint.replaceAll('{id}', timesheetId);

      await _apiService.deleteTimesheet(endpoint);

      _showSuccess("Timesheet deleted.");
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError("Error deleting timesheet: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteRowAction(Map<String, dynamic> payload) async {
    if (_isLoading) return;

    // Get activity ID from the payload (merged from row data)
    final String? activityId = payload['id'];
    String? endpoint = payload['endpoint'];

    if (endpoint == null || activityId == null) {
      _showError("Error: 'Delete Row' action is misconfigured.");
      return;
    }

    // Show confirmation dialog
    final bool didConfirm = await _showDeleteConfirmation(
      "Delete Activity?",
      "Are you sure you want to delete this activity?",
    );
    if (!didConfirm) return;

    setState(() {
      _isLoading = true;
    });
    try {
      // Replace {id} with the actual activity ID
      endpoint = endpoint.replaceAll('{id}', activityId);

      await _apiService.deleteActivity(endpoint);

      // On success, remove it from the local list and refresh
      _sessionActivities.removeWhere((activity) => activity.id == activityId);
      _populateManager();
      _showSuccess("Activity deleted.");
    } catch (e) {
      _showError("Error deleting activity: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ⭐️ 3. NEW HANDLER FOR "EDIT ROW" ICON
  Future<void> _handleEditRowAction(Map<String, dynamic> payload) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final String? endpoint = payload['endpoint']; // Endpoint to get the form
    if (endpoint == null) {
      _showError("Error: 'Edit Row' endpoint not configured.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Get the edit form JSON
      final Map<String, dynamic> editFormJson = await _apiService
          .getFormDefinition(endpoint);

      // 2. Create the ActivityFormModel from the row's data (the payload)
      // This model will be used to pre-fill the form
      final ActivityFormModel activityToEdit = ActivityFormModel.fromMap(
        payload,
      );

      // 3. Navigate to ActivityFormPage, passing the form AND the data
      final updatedActivity = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityFormPage(
            selectedDate: widget.selectedDate,
            formJson: editFormJson,
            initialData: activityToEdit, // ⭐️ Pass the row data
          ),
        ),
      );

      // 4. Handle the result
      if (updatedActivity != null && updatedActivity is ActivityFormModel) {
        // Find the original activity by ID and replace it
        final index = _sessionActivities.indexWhere(
          (a) => a.id == updatedActivity.id,
        );
        if (index != -1) {
          _sessionActivities[index] = updatedActivity;
          _populateManager(); // Refresh table
          _showSuccess("Activity updated.");
        }
      }
    } catch (e) {
      _showError("Error loading edit form: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ... helper methods _showError, _showSuccess, _showDeleteConfirmation remain the same ...
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

  // ⭐️ REPLACE your old _showDeleteConfirmation with this one
  Future<bool> _showDeleteConfirmation(String title, String content) async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title), // Use the title parameter
          content: Text(content), // Use the content parameter
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );
    return didConfirm ?? false; // Return false if dialog is dismissed
  }

  // ... build() and dispose() methods remain the same ...
  @override
  Widget build(BuildContext context) {
    if (widget.initialData.formJson.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Failed to load form definition.")),
      );
    }

    debugPrint(
      "🧩 Manager dataContext: ${jsonEncode(widget.manager.dataContext)}",
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 23, 155),
        title: Text(
          "Timesheet for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: DynamicFormRenderer(
              formDefinition: widget.initialData.formJson,
              manager: widget.manager,
              key: ValueKey(_sessionActivities.length),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
