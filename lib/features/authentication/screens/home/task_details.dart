import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_details_controller.dart';
import 'package:oji_1/features/authentication/screens/Form/part_a.dart';
import 'package:oji_1/features/authentication/screens/Form/part_b.dart';
import 'package:oji_1/features/authentication/screens/Form/part_c.dart';
import 'package:oji_1/features/authentication/screens/Form/part_d.dart';
import 'package:oji_1/features/authentication/screens/Form/part_e.dart';
import 'package:oji_1/features/authentication/screens/Form/part_f.dart';
import 'package:oji_1/features/authentication/screens/Form/part_g.dart';


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
        title: Text(controller.getTaskStatusTitle(widget.task.status)),
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
                      Obx(() => _buildAlignedText("BRM No.", controller.selectedBRM.value)),
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
                Obx(() {
                  if (controller.brmList.isEmpty) {
                    return const CircularProgressIndicator();
                  } else {
                    return _buildBRMDropdown();
                  }
                }),

                const SizedBox(height: 10),

                buildRequiredQuantityInput(),

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

  Widget _buildBRMDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Text(
            "BRM:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedBRM.value.isNotEmpty
                  ? controller.selectedBRM.value
                  : null,
              hint: const Text("Select BRM"),
              items: controller.brmList.map((brm) {
                return DropdownMenuItem(
                  value: brm,
                  child: Text(brm),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedBRM.value = value;
                  controller.fetchMaterialCodes(value); // fetch new material codes
                  controller.selectedMaterialCode.value = ''; // reset material code selection
                }
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget buildRequiredQuantityInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Material Code Dropdown
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Text(
                  "Material Code: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    return DropdownButton<String>(
                      value: controller.selectedMaterialCode.value.isNotEmpty
                          ? controller.selectedMaterialCode.value
                          : null,
                      hint: const Text("Select"),
                      isExpanded: true,
                      items: controller.materialCodes.map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(code),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedMaterialCode.value = value;
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Required Quantity Input
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Text(
                  "Required Quantity: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
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
                  ),
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
    switch (key) {
      case "A":
        Get.to(() => PartA(task: widget.task));
        break;
      case "B":
        Get.to(() => PartB(task: widget.task));
        break;
      case "C":
        Get.to(() => PartC(task: widget.task));
        break;
      case "D":
        Get.to(() => PartD(task: widget.task));
        break;
      case "E":
        Get.to(() => PartE(task: widget.task));
        break;
      case "F":
        Get.to(() => PartF(task: widget.task));
        break;
      case "G":
        Get.to(() => PartG(task: widget.task));
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
    final storage = GetStorage();
    final firstName = storage.read("first_name") ?? "First Name";
    final inisial = storage.read("inisial") ?? "-";
    final group = storage.read("group") ?? "-";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          controller.showShiftInputDialog(
            firstName: widget.task.firstName ?? firstName,
            inisial: widget.task.inisial ?? inisial,
            group: widget.task.group ?? group,
          );
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
            ),
            child: const Text(
              "Transfer Record To Next Shift",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
