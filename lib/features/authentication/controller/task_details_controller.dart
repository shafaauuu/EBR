import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskDetailsController extends GetxController {
  var sectionCompletion = <String, bool>{
    "A": false,
    "B": false,
    "C": false,
    "D": false,
    "E": false,
    "F": false,
    "G": false,
  }.obs;

  final Map<String, String> sectionTitles = {
    "A": "Part A. Line Clearance",
    "B": "Part B. Persiapan dan Inspeksi Mesin",
    "C": "Part C. Penerimaan dan Inspeksi Material",
    "D": "Part D. Instruksi Kerja dan Catatan",
    "E": "Part E. Production Summary",
    "F": "Part F. Label Material, Mesin, dan Proses",
    "G": "Part G. Verifikasi dan Persetujuan",
  };

  final TextEditingController shiftController = TextEditingController();

  void markSectionAsCompleted(String key) {
    sectionCompletion[key] = true;
  }

  void showShiftInputDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Shift Transfer"),
        content: TextField(
          controller: shiftController,
          decoration: const InputDecoration(
            labelText: "Enter Shift Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String shiftName = shiftController.text;
              if (shiftName.isNotEmpty) {
                Get.back();
                Get.snackbar("Success", "Shift transferred to $shiftName",
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
              } else {
                Get.snackbar("Error", "Shift name cannot be empty",
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  String getTaskStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case "ongoing":
        return "Ongoing";
      case "pending":
        return "Pending Review";
      case "completed":
        return "Completed";
      default:
        return "Task Details";
    }
  }
}
