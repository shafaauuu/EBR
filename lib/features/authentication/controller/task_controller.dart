import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oji_1/common/api.dart';
import '../models/task_model.dart';
import '../screens/home/task_details.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  Task? currentTask;
  var isLoading = false.obs;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      print("Fetching tasks from API...");
      final response = await Api.get("tasks");
      if (response != null) {
        print("Tasks response: $response");
        
        // Get current user's NIK from storage
        final String? currentUserNik = storage.read("nik");
        print("Current user NIK: $currentUserNik");
        
        // Convert all tasks from JSON
        List<Task> allTasks = (response as List)
            .map((item) => Task.fromJson(item))
            .toList();
        
        // Filter tasks by current user's NIK if available
        if (currentUserNik != null && currentUserNik.isNotEmpty) {
          tasks.value = allTasks.where((task) => 
            task.assignedTo == currentUserNik
          ).toList();
          print("Filtered to ${tasks.length} tasks assigned to current user");
        } else {
          tasks.value = allTasks;
          print("No user NIK found, showing all ${tasks.length} tasks");
        }
        
        // Sort tasks by created date (newest first)
        tasks.sort((a, b) {
          // If either task doesn't have a createdAt date, use a fallback comparison
          if (a.createdAt == null || b.createdAt == null) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            return a.createdAt == null ? 1 : -1; // Null dates go to the end
          }
          // Compare dates in reverse order (newest first)
          return b.createdAt!.compareTo(a.createdAt!);
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    String? token = storage.read("auth_token");

    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await Api.put("tasks/$taskId/$status",
          {
            'status': status,
          }
      );

      if (response != null) {
        fetchTasks(); // Refresh task list after update
      } else {
        print("Failed to update task status");
      }
    } catch (e) {
      print("Error updating task status: $e");
      Get.snackbar(
        'Error',
        'Failed to update task status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  Future<bool> updateTask(int id, String name, String code, String brmNo, String date, String status) async {
    String? token = storage.read("auth_token");

    if (token == null) {
      print("No token found");
      return false;
    }

    try {
      // First update the status if it has changed
      final currentTask = tasks.firstWhere((task) => task.id == id);
      if (currentTask.status != status) {
        await updateTaskStatus(id, status);
      }
      
      // Then update other task details using the reassign endpoint
      final response = await Api.put("tasks/$id/reassign",
          {
            'assigned_to': storage.read("nik") ?? "",
            // We can't update other fields with the current API,
            // but in a real implementation you would send all updated fields
          }
      );

      if (response != null) {
        fetchTasks(); // Refresh task list after update
        return true;
      } else {
        print("Failed to update task details");
        return false;
      }
    } catch (e) {
      print("Error updating task details: $e");
      return false;
    }
  }

  void showOptionsMenu(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text("View Details"),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => TaskDetails(task: task));
              },
            ),
            if (task.status == "ongoing")
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Task Details"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to task details screen for editing forms A-G
                  Get.to(() => TaskDetails(task: task, isEditing: true));
                },
              ),
            if (task.status == "ongoing")
              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: const Text("Move to Pending"),
                onTap: () {
                  updateTaskStatus(task.id, "pending");
                  Navigator.pop(context);
                },
              ),
            if (task.status == "pending")
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text("Move to Completed"),
                onTap: () {
                  updateTaskStatus(task.id, "completed");
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }
}
