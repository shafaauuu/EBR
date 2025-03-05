import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'task_item.dart';

class OngoingPage extends StatelessWidget {
  const OngoingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      var ongoingTasks = taskController.tasks.where((task) => task.status == 'ongoing').toList();

      return ongoingTasks.isEmpty
          ? const Center(child: Text("No ongoing tasks"))
          : ListView.builder(
        itemCount: ongoingTasks.length,
        itemBuilder: (context, index) {
          return TaskItem(task: ongoingTasks[index]);
        },
      );
    });
  }
}
