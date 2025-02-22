import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs; // Observable list of tasks

  void addTask(Task task) {
    tasks.add(task);
  }

  void removeTask(Task task) {
    tasks.remove(task);
  }

  void showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.remove_red_eye),
              title: const Text('Review'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel Task'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
