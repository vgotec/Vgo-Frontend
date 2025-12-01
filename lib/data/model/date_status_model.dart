// date_status_model.dart
import 'package:flutter/material.dart';

class DateStatusModel {
  final DateTime date;
  final String status;
  final String colorCode;

  DateStatusModel({
    required this.date,
    required this.status,
    required this.colorCode,
  });

  factory DateStatusModel.fromMap(Map<String, dynamic> map) {
    return DateStatusModel(
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'NONE',
      colorCode: map['colorCode'] ?? '#FFFFFF',
    );
  }
}