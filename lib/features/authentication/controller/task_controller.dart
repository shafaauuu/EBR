import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  final storage = GetStorage();
  final String baseUrl = "http://127.0.0.1:8000/api/tasks";

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    String? token = storage.read("auth_token");

    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        tasks.value = jsonData.map((task) => Task.fromJson(task)).toList();
      } else {
        print("Failed to load tasks: ${response.body}");
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  Future<void> updateTaskStatus(String taskCode, String status) async {
    String? token = storage.read("auth_token");

    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$taskCode/$status"), // Correct API for updating task status
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchTasks(); // Refresh task list after update
      } else {
        print("Failed to update task: ${response.body}");
      }
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  void showOptionsMenu(BuildContext context, String taskCode, String status) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (status == "ongoing")
              ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text("Move to Pending"),
                onTap: () {
                  updateTaskStatus(taskCode, "pending");
                  Navigator.pop(context);
                },
              ),
            if (status == "pending")
              ListTile(
                leading: Icon(Icons.check),
                title: Text("Move to Completed"),
                onTap: () {
                  updateTaskStatus(taskCode, "completed"); // Use taskCode
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }
}
