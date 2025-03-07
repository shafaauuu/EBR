import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_details_controller.dart';
import 'package:oji_1/features/authentication/screens/Form/part_a.dart';

import '../Form/part_b.dart';

class TaskDetails extends StatefulWidget {
  final Task task;
  const TaskDetails({super.key, required this.task});

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(controller.getTaskStatusTitle(widget.task.status)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Image.asset('assets/logos/logo_oneject.png', height: 40),
          ),
          Text(
            widget.task.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
              "Code: ${widget.task.code}",
              style: const TextStyle(fontSize: 14),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(thickness: 1),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: controller.sectionTitles.entries.map((entry) {
                return _buildSectionButton(entry.key, entry.value);
              }).toList()
                ..add(const SizedBox(height: 30))
                ..add(_buildShiftButton()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton(String key, String title) {
    return Obx(() {
      bool isCompleted = controller.sectionCompletion[key] ?? false;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: GestureDetector(
          onTap: () => _navigateToSection(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isCompleted
                    ? [Colors.green.shade700, Colors.green.shade400]
                    : [Colors.blue.shade600, Colors.blue.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: isCompleted ? Colors.green.shade300 : Colors.blue.shade300,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _navigateToSection(String key) {
    switch (key) {
      case "A":
        Get.to(() => PartA(task: widget.task));
        break;
      case "B":
        Get.to(() => PartB(task: widget.task));
        break;
      default:
        _showSweetAlert();
    }
  }

  void _showSweetAlert() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          "Not Available",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("This section is under development!"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () => controller.showShiftInputDialog(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade400]),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade300,
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "Transfer Record To Next Shift",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
