import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'package:oji_1/features/authentication/screens/home/task_details.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    // Format dates for display
    String createdDate = "N/A";
    String completedDate = "N/A";
    
    if (task.createdAt != null) {
      createdDate = DateFormat('yyyy-MM-dd').format(task.createdAt!);
    }
    
    if (task.status == "completed" && task.updatedAt != null) {
      completedDate = DateFormat('yyyy-MM-dd').format(task.updatedAt!);
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(task.icon, color: task.color),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.status == "completed")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Completed: $completedDate",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Created: $createdDate",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            else
              Text(
                "Date: ${task.date}",
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              task.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          "Code: ${task.code}",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => taskController.showOptionsMenu(context, task),
        ),
        onTap: () {
          Get.to(() => TaskDetails(task: task));
        },
      ),
    );
  }
}
