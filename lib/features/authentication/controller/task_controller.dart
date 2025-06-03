import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:oji_1/common/api.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  Task? currentTask;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {

    try {
      final response = await Api.get("tasks");
      tasks.value = (response as List)
          .map((item) => Task.fromJson(item))
          .toList();


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
      final response = await Api.put( "tasks/$taskCode/$status",
          {
            'status': status,
          }
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
