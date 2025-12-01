class LeaveModel {
  final String? id;
  final String? employeeId;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final String session;
  final String remarks;
  final String status;
  final double totalDays;

  final Map<String, dynamic> formJson;
  final String message;
  final List<dynamic> leaveBalance;

  LeaveModel({
    this.id,
    this.employeeId,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.session,
    required this.remarks,
    required this.status,
    required this.totalDays,
    required this.formJson,
    required this.message,
    required this.leaveBalance,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    final leave = map["leave"] as Map<String, dynamic>? ?? {};

    return LeaveModel(
      id: leave["id"],
      
      // backend does NOT send employeeId → safe fallback
      employeeId: map["employeeId"] ?? leave["employeeId"],

      leaveTypeName: leave["leaveTypeName"] ?? "",
      startDate: leave["startDate"] ?? "",
      endDate: leave["endDate"] ?? "",
      session: leave["session"] ?? "",
      remarks: leave["remarks"] ?? "",
      status: leave["status"] ?? "",
      totalDays: (leave["totalDays"] as num?)?.toDouble() ?? 0.0,

      formJson: map["formJson"] as Map<String, dynamic>? ?? {},
      message: map["message"] ?? "",
      leaveBalance: map["leaveBalance"] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employeeId": employeeId,
      "leaveTypeName": leaveTypeName,
      "startDate": startDate,
      "endDate": endDate,
      "session": session,
      "remarks": remarks,
      "status": status,
      "totalDays": totalDays,
      "formJson": formJson,
      "message": message,
      "leaveBalance": leaveBalance,
    };
  }
}
