import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';
import 'task_item.dart';

class OngoingPage extends StatefulWidget {
  const OngoingPage({super.key});

  @override
  State<OngoingPage> createState() => _OngoingPageState();
}

class _OngoingPageState extends State<OngoingPage> {
  final taskController = Get.find<TaskController>();
  String searchText = '';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var filteredTasks = taskController.tasks.where((task) {
        final matchesSearch = searchText.isEmpty ||
            task.name.toLowerCase().contains(searchText.toLowerCase());

        final matchesDate = selectedDate == null || (task.date != null && (() {
          final taskDate = DateTime.parse(task.date!).toLocal();
          return taskDate.year == selectedDate!.year &&
              taskDate.month == selectedDate!.month &&
              taskDate.day == selectedDate!.day;
        })());

        return task.status == 'ongoing' && matchesSearch && matchesDate;
      }).toList();


      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search bar on the left
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      searchText = value;
                    }),
                  ),
                ),
                const SizedBox(width: 10),

                // Date filter button on the right with modern styling
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  label: Text(
                    selectedDate == null
                        ? 'Filter by Date'
                        : selectedDate.toString().substring(0, 10),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Change color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        selectedDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("No ongoing tasks"))
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return TaskItem(task: filteredTasks[index]);
              },
            ),
          ),
        ],
      );
    });
  }
}
