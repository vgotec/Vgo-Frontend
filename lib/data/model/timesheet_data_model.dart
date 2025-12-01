import 'package:timesheet_ui/data/model/activity_form_model.dart'; 

class TimesheetDataModel {
  final String id;
  final String workDate;
  final String status;
  final double? totalHours;
  final List<ActivityFormModel> entries;
  final Map<String, dynamic> formJson; 

  TimesheetDataModel({
    required this.id,
    required this.workDate,
    required this.status,
    this.totalHours,
    required this.entries,
    required this.formJson, 
  });

  factory TimesheetDataModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? entryData = map['entries'] as List<dynamic>?;
    final List<ActivityFormModel> entryList = entryData
        ?.map((e) => ActivityFormModel.fromMap(e as Map<String, dynamic>))
        .toList() ?? [];

    return TimesheetDataModel(
      id: map['id'] ?? '',
      workDate: map['workDate'] ?? '',
      status: map['status'] ?? 'NOT_SUBMITTED',
      totalHours: (map['totalHours'] as num?)?.toDouble(),
      entries: entryList,
      formJson: map['formJson'] as Map<String, dynamic>? ?? {}, 
    );
  }
}