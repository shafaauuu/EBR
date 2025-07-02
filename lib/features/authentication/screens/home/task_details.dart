import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:async';

import 'package:oji_1/features/authentication/controller/task_controller.dart';

import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_details_controller.dart';

import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_a.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_b.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_c.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_d.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_e.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_f.dart';
import 'package:oji_1/features/authentication/screens/Form/Needle_Assy/part_g.dart';

import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_a.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_b.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_c.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_d.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_e.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_f.dart';
import 'package:oji_1/features/authentication/screens/Form/Assy_Syringe/part_g.dart';

import 'package:oji_1/features/authentication/screens/Form/Blister/part_a.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_b.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_c.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_d.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_e.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_f.dart';
import 'package:oji_1/features/authentication/screens/Form/Blister/part_g.dart';

import 'package:oji_1/features/authentication/screens/Form/Injection/part_a.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_b.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_c.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_d.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_e.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_f.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/part_g.dart';

import '../../models/material_model.dart';

class TaskDetails extends StatefulWidget {
  final Task task;
  final bool isEditing;
  
  const TaskDetails({
    super.key, 
    required this.task,
    this.isEditing = false,
  });

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final TaskController taskController = Get.find<TaskController>();
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Store the current task ID in GetStorage for use in shift transfer
    storage.write("current_task_id", widget.task.id);
  }

  @override
  void dispose() {
    // Clear the current task ID when leaving the screen
    storage.remove("current_task_id");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchCategory(widget.task.brmNo);
    controller.fetchMaterialCodes(widget.task.brmNo);
    controller.fetchMachinesByBRM(widget.task.brmNo);
    controller.setBRM(widget.task.brmNo);
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please rotate your device to landscape mode.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.isEditing 
          ? "Edit ${controller.getTaskStatusTitle(widget.task.status)}" 
          : controller.getTaskStatusTitle(widget.task.status)
        ),
        actions: widget.isEditing 
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.edit, color: Colors.blue),
              )
            ] 
          : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // First column: Logo
                SizedBox(
                  width: 250,
                  child: Image.asset('assets/logos/logo_oneject.png', height: 50),
                ),

                const SizedBox(width: 16),

                // Second column: Code & Name
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BATCH RECORD",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildAlignedText("P/C Code", widget.task.code),
                      _buildAlignedText("P/C Name", widget.task.name),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Third column: BRM, Rev No, Eff. Date
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAlignedText("BRM No.", widget.task.brmNo),
                      _buildAlignedText("Rev No.", ""),
                      _buildAlignedText("Eff. Date", ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 10),

                buildMaterialSearchInput(),

                ...controller.sectionTitles.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.3),
                    child: _buildSectionButton(entry.key, entry.value),
                  );
                }).toList(),

                const SizedBox(height: 40),

                _buildShiftButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignedText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label :",
            style: const TextStyle(fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget buildMaterialSearchInput() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Material Field
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Search Material:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TypeAheadField<MaterialModel>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller.searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter code, description, or group",
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (controller.selectedBRM.value.isEmpty) {
                      Get.snackbar("Warning", "Please select a BRM first.",
                          backgroundColor: Colors.orange, colorText: Colors.white);
                      return [];
                    }

                    controller.searchQuery.value = pattern;
                    return await controller.searchMaterials();
                  },
                  itemBuilder: (context, MaterialModel suggestion) {
                    return ListTile(
                      title: Text('${suggestion.materialCode} - ${suggestion.materialDesc} - ${suggestion.materialGroup}'),
                      // subtitle: Text(suggestion.materialGroup),
                    );
                  },
                  onSuggestionSelected: (MaterialModel suggestion) {
                    controller.selectedMaterialCode.value = suggestion.materialCode;
                    controller.selectedMaterialDisplay.value =
                    '${suggestion.materialCode} - ${suggestion.materialDesc}';
                    controller.searchController.text = controller.selectedMaterialDisplay.value;
                  },
                  noItemsFoundBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No materials found'),
                  ),
                  loadingBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (context, error) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error: ${controller.errorMessage.value}'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 🔢 Required Quantity Field
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Required Quantity:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 1,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "200",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onChanged: (value) {
                    controller.requiredQuantity.value = value;
                  },
                ),
              ],
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
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isCompleted
                    ? [Colors.green.shade700, Colors.green.shade400]
                    : [Colors.blue.shade600, Colors.blue.shade400],
              ),
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
    // Check if BRM data is still loading
    if (controller.isBrmLoading.value) {
      _showLoadingDialog();
      return;
    }

    final category = controller.selectedCategory.value;

    switch (category) {

      case "Blister":
        switch (key) {
          case "A": Get.to(() => PartA_Blister(task: widget.task)); break;
          case "B": Get.to(() => PartB_Blister(task: widget.task)); break;
          case "C": Get.to(() => PartC_Blister(task: widget.task,
                                             selectedMaterialCode: controller.selectedMaterialCode.value,
                                             requiredQuantity: int.tryParse(controller.requiredQuantity.value) ?? 1)); break;
          case "D": Get.to(() => PartD(task: widget.task, selectedMaterialCode: controller.selectedMaterialCode.value)); break;
          case "E": Get.to(() => PartE_Blister(task: widget.task)); break;
          case "F": Get.to(() => PartF_Blister(task: widget.task)); break;
          case "G": Get.to(() => PartG_Blister(task: widget.task)); break;
          default: _showNotAvailableAlert();
        }
        break;

      case "Assy Syringe":
        switch (key) {
          case "A": Get.to(() => PartA_Syringe(task: widget.task)); break;
          case "B": Get.to(() => PartB_Syringe(task: widget.task)); break;
          case "C": Get.to(() => PartC_Syringe(task: widget.task,
                  selectedMaterialCode: controller.selectedMaterialCode.value,
        requiredQuantity: int.tryParse(controller.requiredQuantity.value) ?? 1)); break;
          case "D": Get.to(() => PartD(task: widget.task, selectedMaterialCode: controller.selectedMaterialCode.value)); break;
          case "E": Get.to(() => PartE_Syringe(task: widget.task)); break;
          case "F": Get.to(() => PartF_Syringe(task: widget.task)); break;
          case "G": Get.to(() => PartG_Syringe(task: widget.task)); break;
          default: _showNotAvailableAlert();
        }
        break;

      case "Injection":
        switch (key) {
          case "A": Get.to(() => PartA_Injection(task: widget.task)); break;
          case "B": Get.to(() => PartB_Injection(task: widget.task)); break;
          case "C": Get.to(() => PartC_Injection(task: widget.task,
              selectedMaterialCode: controller.selectedMaterialCode.value,
              requiredQuantity: int.tryParse(controller.requiredQuantity.value) ?? 1)); break;
          case "D": Get.to(() => PartD(task: widget.task, selectedMaterialCode: controller.selectedMaterialCode.value)); break;
          case "E": Get.to(() => PartE_Injection(task: widget.task)); break;
          case "F": Get.to(() => PartF_Injection(task: widget.task)); break;
          case "G": Get.to(() => PartG_Injection(task: widget.task)); break;
          default: _showNotAvailableAlert();
        }
        break;

      case "Assy Needle":
        switch (key) {
          case "A": Get.to(() => PartA_NeedleAssy(task: widget.task)); break;
          case "B": Get.to(() => PartB_NeedleAssy(task: widget.task)); break;
          case "C": Get.to(() => PartC_NeedleAssy(task: widget.task,
              selectedMaterialCode: controller.selectedMaterialCode.value,
              requiredQuantity: int.tryParse(controller.requiredQuantity.value) ?? 1)); break;
          case "D": Get.to(() => PartD(task: widget.task, selectedMaterialCode: controller.selectedMaterialCode.value)); break;
          case "E": Get.to(() => PartE_NeedleAssy(task: widget.task)); break;
          case "F": Get.to(() => PartF_NeedleAssy(task: widget.task)); break;
          case "G": Get.to(() => PartG_NeedleAssy(task: widget.task)); break;
          default: _showNotAvailableAlert();
        }
        break;

      default:
        _showNotAvailableAlert();
    }
  }

  // Show loading dialog when BRM data is being fetched
  void _showLoadingDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dialog from being dismissed by back button
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Loading BRM data...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please wait while we fetch the necessary data for this form.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Prevent dialog from being dismissed by tapping outside
    );

    // Check periodically if BRM loading is complete
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!controller.isBrmLoading.value) {
        timer.cancel();
        Get.back(); // Close the dialog
      }
    });
  }

  // Show alert for features that are not available
  void _showNotAvailableAlert() {
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
        onTap: () async {
          print("Shift button tapped");
          final result = await controller.showShiftInputDialog();
          print("Dialog result: $result");
          
          if (result == true) {
            print("Task transferred successfully, navigating to home");
            // First refresh tasks list to ensure it's up-to-date
            await taskController.fetchTasks();
            
            // Force clear the task list cache
            taskController.tasks.clear();
            
            // Navigate back to home view
            // First close any open snackbars
            Get.closeAllSnackbars();
            
            // Navigate back to home screen
            Get.offNamedUntil('/home', (route) => false);
            
            // Refresh task list after navigation
            Future.delayed(const Duration(milliseconds: 300), () async {
              print("Refreshing tasks after navigation");
              await taskController.fetchTasks();
              taskController.update();
            });
          }
        },
        child: Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade700,
                  Colors.orange.shade400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  "Shift Transfer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
