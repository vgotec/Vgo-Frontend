import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// 📦 Dynamic Form Kit
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/renderer/dynamic_form_renderer.dart';
import 'package:timesheet_ui/data/model/leave_model.dart';
import 'package:timesheet_ui/data/model/timesheet_data_model.dart';
import 'package:timesheet_ui/screens/leave_form_page.dart';
// 📱 Timesheet UI
import 'package:timesheet_ui/screens/timesheet_form_screen.dart';
import 'package:timesheet_ui/data/model/activity_form_model.dart';
import 'package:timesheet_ui/data/model/date_status_model.dart';
import 'package:timesheet_ui/data/services/activity_api_service.dart';

/// ---------------------------------------------------------------------------
/// 📅 CalendarFormScreen
/// ---------------------------------------------------------------------------
/// This screen loads a calendar form dynamically from JSON and
/// connects it with API-driven data (color-coded date statuses).
/// ---------------------------------------------------------------------------
class CalendarFormScreen extends StatefulWidget {
  final String formEndpoint;
  const CalendarFormScreen({super.key, required this.formEndpoint});

  @override
  State<CalendarFormScreen> createState() => _CalendarFormScreenState();
}

class _CalendarFormScreenState extends State<CalendarFormScreen> {
  // ---------------------------------------------------------------------------
  // 🧩 State & Controllers
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? formDefinition;

  final FormStateManager _calendarManager = FormStateManager();
  final FormStateManager _timesheetManager = FormStateManager();

  final ActivityApiService _apiService = ActivityApiService();

  final List<ActivityFormModel> _timesheetActivities = [];

  DateTime _currentCalendarMonth = DateTime.now();

  // ---------------------------------------------------------------------------
  // 🔄 Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Load form JSON first, then fetch month data.
    _loadForm().then((_) {
      // Check if formDefinition is not null before fetching
      if (formDefinition != null) {
        _fetchCalendarData(_currentCalendarMonth);
      }
    });

    _listenToActions();
  }

  @override
  void dispose() {
    _calendarManager.dispose();
    _timesheetManager.dispose();
    super.dispose();
  }

  // ----------------------------------------------
  // 📥 Load Form Definition
  // ----------------------------------------------

  // In CalendarFormScreen.dart

  // ---------------------------------------------------------------------------
  // 📥 Load Form Definition
  // ---------------------------------------------------------------------------

  Future<void> _loadForm() async {
    try {
      // ⭐️ 4. UPDATE THIS: Use the endpoint passed from the widget
      // We removed the hardcoded string
      final Map<String, dynamic> jsonData = await _apiService.getFormDefinition(
        widget.formEndpoint,
      ); // <-- Use widget property

      setState(() {
        formDefinition = jsonData;
      });
    } catch (e) {
      print("❌ Failed to load form from API (${widget.formEndpoint}): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Could not load form configuration.")),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🌐 Fetch Calendar Data (for the selected month)
  // ---------------------------------------------------------------------------

  Future<void> _fetchCalendarData(DateTime date) async {
    try {
      // Locate the API endpoint from form JSON.
      final config =
          formDefinition?['layout']?['rows']?[0]?['fields']?[0]?['config'];
      final baseEndpoint = config?['api']?['endpoint'] as String?;

      if (baseEndpoint == null) {
        print("⚠️ Error: 'api.endpoint' not found in calendar_form.json");
        return;
      }

      // Construct full endpoint URL: e.g. `/calendar/2025/11`
      final String url = "$baseEndpoint/${date.year}/${date.month}";

      // Fetch date statuses from API
      final List<dynamic> responseData = await _apiService.get(url);

      // Map response into model objects
      final List<DateStatusModel> statuses = responseData
          .map((data) => DateStatusModel.fromMap(data))
          .toList();

      // Convert to a lookup map: { dateOnly(Date): colorCode }
      final Map<DateTime, String> colorMap = {
        for (var status in statuses)
          DateUtils.dateOnly(status.date): status.colorCode,
      };

      // ✅ Update the calendar manager so that CalendarWidget can react
      _calendarManager.updateDataContext({"dateStatuses": colorMap});

      setState(() {
        _currentCalendarMonth = date;
      });
    } catch (e) {
      print("❌ Failed to load calendar statuses: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 🎯 Action Listener (handles calendar interactions)
  // ---------------------------------------------------------------------------

  void _listenToActions() {
    _calendarManager.onAction.addListener(() async {
      final action = _calendarManager.onAction.value;
      if (action == null) return;

      switch (action.type) {
        // 🗓️ When user selects a date
        case 'navigateTo':
          final payload = action.payload ?? {};

          final selectedString = payload['selectedDate'];
          final endpoint = payload['endpoint'];
          final navTarget = payload['navigationTarget'];

          if (selectedString == null || endpoint == null || navTarget == null) {
            print("⚠ Missing fields in navigateTo payload.");
            return;
          }

          final selectedDate =
              DateTime.tryParse(selectedString) ?? DateTime.now();

          try {
            // ⭐ TIMESHEET FLOW (unchanged)
            if (navTarget == "TimesheetFormScreen") {
              final responseJson = await _apiService.getTimesheetData(
                endpoint,
                selectedDate,
              );

              final model = TimesheetDataModel.fromMap(responseJson);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimesheetFormScreen(
                    selectedDate: selectedDate,
                    manager: _timesheetManager,
                    initialData: model,
                  ),
                ),
              );
              return;
            }

            // ⭐ LEAVE FLOW — COMPLETELY UPDATED
            if (navTarget == "LeaveForm") {
              // 1️⃣ Call backend (same endpoint for edit + create)
              final raw = await _apiService.getLeaveData(
                endpoint,
                selectedDate,
              );

              // 2️⃣ Parse model (may be null)
              final LeaveModel? leave = raw['leave'] != null
                  ? LeaveModel.fromMap(raw['leave'])
                  : null;

              // 3️⃣ Get appropriate formJson
              final Map<String, dynamic> formJson = raw['formJson'] ?? {};

              // 4️⃣ Navigate directly to create/edit form
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaveFormPage(
                    selectedDate: selectedDate,
                    formJson: formJson,
                    initialData: leave, // ⭐ null → create, not null → edit
                  ),
                ),
              );
              return;
            }

            print("⚠ Unknown navigationTarget: $navTarget");
          } catch (e) {
            print("❌ Navigation error: $e");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
          break;

        case 'monthChanged':
          final newDate = DateTime.tryParse(action.payload?['newMonth']);
          if (newDate != null &&
              (newDate.month != _currentCalendarMonth.month ||
                  newDate.year != _currentCalendarMonth.year)) {
            await _fetchCalendarData(newDate);
          }
          break;

        // 🚫 Default: ignore unknown actions
        default:
          print("⚙️ Unhandled action type: ${action.type}");
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 🧱 UI Rendering
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: formDefinition == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(0),
                child: DynamicFormRenderer(
                  key: ValueKey("formLoaded"),
                  formDefinition: formDefinition!,
                  manager: _calendarManager,
                ),
              ),
      ),
    );
  }
}
