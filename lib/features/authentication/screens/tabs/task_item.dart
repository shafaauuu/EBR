import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'package:oji_1/features/authentication/screens/home/task_details.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(task.icon, color: task.color),
        subtitle: Text(
          "Code: ${task.code}",
          style: const TextStyle(fontSize: 12),
        ),
        title: Text(
          task.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => taskController.showOptionsMenu(context, task.code, task.status),
        ),
        onTap: () {
          Get.to(() => TaskDetailsPage(task: task));
        },
      ),
    );
  }
}
