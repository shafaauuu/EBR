import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';

class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    Task completedTask = Task(
      code: 'XXX-BRL-XX XmL-LL-HRT',
      name: 'XXXXX-XX-XXX-Safeject',
      icon: Icons.check_circle,
      color: Colors.green,
    );

    return ListView(
      children: [
        TaskItem(task: completedTask), // Pass a Task object instead of raw values
      ],
    );
  }
}
