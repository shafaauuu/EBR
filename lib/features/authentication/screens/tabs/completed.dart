import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'task_item.dart';

class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      var completedTasks = taskController.tasks.where((task) => task.status == 'completed').toList();

      return completedTasks.isEmpty
          ? const Center(child: Text("No completed tasks"))
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          return TaskItem(task: completedTasks[index]);
        },
      );
    });
  }
}
