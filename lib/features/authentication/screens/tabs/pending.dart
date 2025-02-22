import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Task pendingTask = Task(
      code: 'XXX-BRL-XX XmL-LL-HRT',
      name: 'XXXXX-XX-XXX-Safeject',
      icon: Icons.warning,
      color: Colors.red,
    );

    return ListView(
      children: [
        TaskItem(task: pendingTask), // Pass a Task object instead of raw values
      ],
    );
  }
}
