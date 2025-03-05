import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'task_item.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      var pendingTasks = taskController.tasks.where((task) => task.status == 'pending').toList();

      return pendingTasks.isEmpty
          ? const Center(child: Text("No pending tasks"))
          : ListView.builder(
        itemCount: pendingTasks.length,
        itemBuilder: (context, index) {
          return TaskItem(task: pendingTasks[index]);
        },
      );
    });
  }
}
