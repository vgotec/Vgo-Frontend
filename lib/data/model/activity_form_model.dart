// lib/data/models/activity_form_model.dart

class ActivityFormModel {
  final String? id;
  final String? project;
  final String? activity;
  final String? category;
  final String? description;
  final String? startTime;
  final String? endTime;
  final double? workHours;
  final String? date; 

  ActivityFormModel({
    this.id,
    this.project,
    this.activity,
    this.category,
    this.description,
    this.startTime,
    this.endTime,
    this.workHours,
    this.date, 
  });

  factory ActivityFormModel.fromMap(Map<String, dynamic> map) {
    return ActivityFormModel(
      id: map['id']?.toString(),
      project: map['project']?.toString(),
      activity: map['activity']?.toString(),
      category: map['category']?.toString(),
      description: map['description']?.toString(),
      startTime: map['startTime']?.toString(),
      endTime: map['endTime']?.toString(),
      workHours: (map['workHours'] as num?)?.toDouble(),
      date: map['workDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'project': project,
      'activity': activity,
      'category': category,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'workHours': workHours,
      'workDate': date,
    };
  }

  ActivityFormModel copyWith({
    String? id,
    String? project,
    String? activity,
    String? category,
    String? description,
    String? startTime,
    String? endTime,
    double? workHours,
    String? date,
  }) {
    return ActivityFormModel(
      id: id ?? this.id,
      project: project ?? this.project,
      activity: activity ?? this.activity,
      category: category ?? this.category,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      workHours: workHours ?? this.workHours,
      date: date ?? this.date,
    );
  }
}