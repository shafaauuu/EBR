import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';

class OngoingPage extends StatelessWidget {
  const OngoingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Task ongoingTask = Task(
      code: 'MLD-BRL-DS 5mL-LL-HRT',
      name: 'Packaging DS 5mL Safeject',
      icon: Icons.access_time_filled,
      color: Colors.blue,
    );

    return ListView(
      children: [
        TaskItem(task: ongoingTask),
      ],
    );
  }
}
