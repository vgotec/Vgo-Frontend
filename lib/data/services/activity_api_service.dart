import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timesheet_ui/data/model/activity_form_model.dart';


class ActivityApiService {
  final String baseUrl='https://vgo-backend.onrender.com';

  // ActivityApiService({required this.baseUrl});

 /// Save a new or existing activity form.
 /// Save a new or existing activity form.
  Future<ActivityFormModel> saveActivity({
    required ActivityFormModel form,
    required String endpoint, // ⭐️ ADDED
    required DateTime date,   // ⭐️ ADDED
  }) async {
    
    // ⭐️ DYNAMICALLY BUILD THE URL ⭐️
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    // 'endpoint' will be something like: "/api/activities/create/f0c6b828-5177-420d-b237-f5e499359eb3"
    // So we just add the date string.
    final url = Uri.parse('$baseUrl$endpoint/$dateString');

    debugPrint("🚀 Saving activity to: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(form.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ActivityFormModel.fromMap(data);
    } else {
      throw Exception(
        'Failed to save activity (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }


  Future<ActivityFormModel> updateActivity({
    required ActivityFormModel form,
    required String endpoint,
    required DateTime date,
  }) async {
    
    // 1. Get the activity ID from the form model
    final String? activityId = form.id;
    if (activityId == null) {
      throw Exception('Failed to update: Activity ID is missing.');
    }
    
    // 2. Replace the {id} placeholder in the endpoint
    final String finalEndpoint = endpoint.replaceAll('{id}', activityId);
    
    // 3. Create the full URL
    // We add the date here just like saveActivity, in case your API needs it
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('$baseUrl$finalEndpoint');
    
    debugPrint("🚀 Updating Activity at: $url");

    // 4. Use http.PUT (which is more correct for updates) or http.POST
    final response = await http.put( // 👈 Using PUT
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(form.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ActivityFormModel.fromMap(data);
    } else {
      throw Exception(
        'Failed to update activity (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

 Future<Map<String, dynamic>> getFormDefinition(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    // You can add auth headers here if needed
    // final response = await http.get(url, headers: { ... });
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // It's safer to decode here so the UI doesn't have to
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to load form (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

  
/// Deletes a single activity by its ID.
  /// Endpoint should be the full, final URL (e.g., /api/activities/delete/123-abc)
  Future<bool> deleteActivity(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    debugPrint("🗑️ Deleting Activity at: $url");

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content
      debugPrint("✅ Activity deleted.");
      return true;
    } else {
      throw Exception(
        'Failed to delete activity (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

  Future<List<dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    // You can add auth headers here if needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Return the raw list so the model can parse it
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Failed to GET data from $endpoint (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

// In ActivityApiService.dart

Future<Map<String, dynamic>> getTimesheetData(String endpointPath, DateTime date) async {
  final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  final String endpoint = "$endpointPath/$dateString";
  final url = Uri.parse('$baseUrl$endpoint');

  // ⭐️ NOTE: You are using POST, which is fine if the server expects it
  final response = await http.post(url); 

  if (response.statusCode == 200) {
    // ⭐️⭐️⭐️ THE FIX ⭐️⭐️⭐️
    // The response body is a single JSON object (a Map), not a List.
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    
    // Return the map directly.
    return responseData;
    // ⭐️⭐️⭐️ END OF FIX ⭐️⭐️⭐️
  } else {
    throw Exception('Failed to load timesheet data: ${response.statusCode}');
  }
}

// In ActivityApiService.dart

  /// Submits the timesheet status (e.g., "SUBMITTED")
  /// Endpoint should be the full, final URL.
  Future<bool> submitTimesheetStatus(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    debugPrint("🚀 Submitting Timesheet Status to: $url");

    final response = await http.put( // Or http.put, depending on your API
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      debugPrint("✅ Timesheet status updated.");
      return true;
    } else {
      throw Exception(
        'Failed to submit timesheet (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

  /// Deletes a timesheet by its ID.
  /// Endpoint should be the full, final URL.
  Future<bool> deleteTimesheet(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    debugPrint("🗑️ Deleting Timesheet at: $url");

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content is also a success
      debugPrint("✅ Timesheet deleted.");
      return true;
    } else {
      throw Exception(
        'Failed to delete timesheet (status: ${response.statusCode}) → ${response.body}',
      );
    }
  }

Future<Map<String, dynamic>> getLeaveData(String endpointPath, DateTime date) async {
  final String dateString =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  final String endpoint = "$endpointPath/$dateString";
  final url = Uri.parse('$baseUrl$endpoint');

  debugPrint("📡 Fetching leave data from: $url");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception("Failed to load leave data: ${response.statusCode}");
  }
}

  Future<Map<String, dynamic>> _handleMapResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Future.value(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
      "API Error (${response.statusCode}) → ${response.body}",
    );
  }

  Future<List<dynamic>> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      return Future.value(jsonDecode(response.body) as List<dynamic>);
    }
    throw Exception(
      "API Error (${response.statusCode}) → ${response.body}",
    );
  }

   Future<bool> deleteJson(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint("DELETE → $url");

    final response = await http.delete(url);
    if (response.statusCode == 200 || response.statusCode == 204) return true;

    throw Exception("Delete failed (${response.statusCode}) → ${response.body}");
  }

  // ---------------------------------------------------------------------------
  // 📌 GENERIC POST (Map response)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> postJson(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint("POST → $url");
    debugPrint("BODY → $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }

  // ---------------------------------------------------------------------------
  // 📌 GENERIC PUT (Map response)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> putJson(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint("PUT → $url");
    debugPrint("BODY → $body");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }



}
