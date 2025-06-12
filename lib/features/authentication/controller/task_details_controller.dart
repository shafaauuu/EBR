import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:oji_1/common/api.dart';
import '../models/material_model.dart';
import '../models/task_model.dart';
import '../screens/Form/Assy_Syringe/part_c.dart';

class TaskDetailsController extends GetxController {
  var selectedMaterialCode = ''.obs;
  var selectedMaterialDisplay = ''.obs;
  var requiredQuantity = ''.obs;
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;
  var materials = <MaterialModel>[].obs;
  var isLoading = false.obs; // To track loading state
  var errorMessage = ''.obs; // To show error messages if any
  Map<String, String?> selectedValues = {};

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
    "B": "Part B. Persiapan dan Inspeksi Mesin dan Perlengkapan",
    "C": "Part C. Penerimaan dan Inspeksi Material/Komponen",
    "D": "Part D. Instruksi Kerja dan Catatan",
    "E": "Part E. Production Summary",
    "F": "Part F. Label Material, Mesin, dan Proses",
    "G": "Part G. Verifikasi dan Persetujuan",
  };

  final TextEditingController shiftController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  void markSectionAsCompleted(String key) {
    sectionCompletion[key] = true;
  }


  void showShiftInputDialog({
    required String firstName,
    required String inisial,
    required String group,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text("Shift Transfer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $firstName"),
            Text("Inisial: $inisial"),
            Text("Group: $group"),
            const SizedBox(height: 12),
            TextField(
              controller: shiftController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: const InputDecoration(
                labelText: "Enter Shift Group",
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                Get.snackbar(
                  "Success",
                  "Shift transferred to Group $shiftName",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  "Error",
                  "Shift name cannot be empty",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
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

  // Observable BRM List
  RxList<String> brmList = <String>[].obs;

  // Selected BRM
  RxString selectedBRM = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBRMList();

    // Listen to BRM changes
    ever(selectedBRM, (brm) {
      searchQuery.value = '';
      materials.clear();
      searchController.clear(); // <--  clear text field!

      if (brm.isNotEmpty) {
        fetchMaterialCodes(brm);
        fetchCategory(brm);
      }
    });

  }


  // Fetch BRM List
  Future<void> fetchBRMList() async {
    try {
      final data = await Api.get("brms");

        // Step 1: Extract, trim, and clean the data
        List<String> rawList = List<String>.from(data.map((item) => item['brm_no'].toString().trim()));

        // Step 2: Remove duplicates using Set
        List<String> uniqueList = rawList.toSet().toList();

        // Step 3: Sort the list
        uniqueList.sort((a, b) => a.compareTo(b));

        // Step 4: Assign to the observable list
        brmList.value = uniqueList;

        print('BRM List Fetched: $brmList');

    } catch (e) {
      Get.snackbar("Error", "Failed to load BRM list: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void fetchBRMData(String brmNumber) async {
    try {
      final encodedBRM = Uri.encodeComponent(brmNumber.trim());
      final data = await Api.get("brms/$encodedBRM");

    } catch (e) {
      Get.snackbar("Error", "Failed to fetch BRM details: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  RxList<String> materialCodes = <String>[].obs;

  Future<void> fetchMaterialCodes(String brmNo) async {
    try {
      final encodedBRM = Uri.encodeComponent(brmNo.trim());
      final data = await Api.get("brms/$encodedBRM/materials") as List<dynamic>;

        final fetchedCodes = data.map((code) => code.toString()).toList();
        final uniqueCodes = fetchedCodes.toSet().toList();

        materialCodes.value = uniqueCodes;

        // 💡 Fix: Reset selectedMaterialCode if it doesn't exist in the new list
        if (!fetchedCodes.contains(selectedMaterialCode.value)) {
          selectedMaterialCode.value = '';
        }

        print('Fetched material codes: $fetchedCodes');

    } catch (e) {
      materialCodes.clear();
      selectedMaterialCode.value = ''; // 💡 Important to reset here as well
      Get.snackbar("Error", "Error fetching material codes: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchCategory(String brmNo) async {
    final encodedBRM = Uri.encodeComponent(brmNo.trim());

    try {
      final response = await Api.get("brms/$encodedBRM/category");

        selectedCategory.value = response['category'];
        print("Fetched category: ${selectedCategory.value}");
    } catch (e) {
      print("Exception fetching category: $e");
    }
  }

  Future<List<MaterialModel>> searchMaterials() async {
    if (searchQuery.value.isEmpty || selectedBRM.value.isEmpty) {
      materials.clear();
      return [];
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await Api.get("materials/search?search=${searchQuery.value}&brm=${selectedBRM.value}") as List<dynamic>;

        materials.value = data.map((item) => MaterialModel.fromJson(item)).toList();

    } catch (e) {
      errorMessage.value = 'Error fetching materials: $e';
    } finally {
      isLoading.value = false;
    }

    return materials;
  }

  RxList<Map<String, dynamic>> machines = <Map<String, dynamic>>[].obs;

  void setBRM(String brmNo) {
    selectedBRM.value = brmNo;
    fetchMachinesByBRM(brmNo);
  }

  Future<void> fetchMachinesByBRM(String brmNo) async {
    try {
      final data = await Api.get("machines/by-brm/$brmNo");
        // Assuming the response contains a 'machines' key with a list of machines
        if (data['machines'] != null) {
          machines.value = List<Map<String, dynamic>>.from(data['machines']);
        } else {
          machines.clear();
          print("No machines data available.");
        }
    } catch (e) {
      machines.clear();
      print("Error fetching machines: $e");
    }
  }

  Future<bool> submitQualificationDataAssySyringe(dynamic data) async {
    try {
      final response = await Api.post("form-b-assy-syringe", data);

      return true;

    } catch (e) {
      print("Submit error: $e");
      return false;
    }
  }

  Future<void> fetchFormBAssySyringeData(String id) async {
    final response = await Api.get("form-b-assy-syringe/$id");
    final item = response['data']; // It's a single object

    final machineId = item['machine_id'];
    final terkualifikasi = item['terkualifikasi'];

    if (terkualifikasi == true) {
      selectedValues[machineId] = "Terkualifikasi";
    } else if (terkualifikasi == false) {
      selectedValues[machineId] = "Tidak Terkualifikasi";
    } else {
      selectedValues[machineId] = "N/A";
    }

    update(); // triggers UI refresh if using GetBuilder
  }

  Future<bool> submitQualificationDataBlister(dynamic data) async {
    try {
      final response = await Api.post("form-b-blister", data);
        return true;

    } catch (e) {
      print("Submit error: $e");
      return false;
    }
  }

  Future<void> fetchFormBBlisterData(String id) async {
    final response = await Api.get("form-b-blister/$id");
    final item = response['data']; // It's a single object

    final machineId = item['machine_id'];
    final terkualifikasi = item['terkualifikasi'];

    if (terkualifikasi == true) {
      selectedValues[machineId] = "Terkualifikasi";
    } else if (terkualifikasi == false) {
      selectedValues[machineId] = "Tidak Terkualifikasi";
    } else {
      selectedValues[machineId] = "N/A";
    }

    update(); // triggers UI refresh if using GetBuilder
  }


  Future<bool> submitQualificationDataInjection(dynamic data) async {
    try {
      final response = await Api.post("form-b-injection", data);

      return true;

    } catch (e) {
      print("Submit error: $e");
      return false;
    }
  }

  Future<void> fetchFormBInjectionData(String id) async {
    final response = await Api.get("form-b-injection/$id");
    final item = response['data']; // It's a single object

    final machineId = item['machine_id'];
    final terkualifikasi = item['terkualifikasi'];

    if (terkualifikasi == true) {
      selectedValues[machineId] = "Terkualifikasi";
    } else if (terkualifikasi == false) {
      selectedValues[machineId] = "Tidak Terkualifikasi";
    } else {
      selectedValues[machineId] = "N/A";
    }

    update(); // triggers UI refresh if using GetBuilder
  }


  Future<bool> submitQualificationDataNeedleAssy(dynamic data) async {
    try {
      final response = await Api.post("form-b-needle-assy", data);

      return true;

    } catch (e) {
      print("Submit error: $e");
      return false;
    }
  }

  Future<void> fetchFormBNeedleAssyData(String id) async {
    final response = await Api.get("form-b-needle-assy/$id");
    final item = response['data']; // It's a single object

    final machineId = item['machine_id'];
    final terkualifikasi = item['terkualifikasi'];

    if (terkualifikasi == true) {
      selectedValues[machineId] = "Terkualifikasi";
    } else if (terkualifikasi == false) {
      selectedValues[machineId] = "Tidak Terkualifikasi";
    } else {
      selectedValues[machineId] = "N/A";
    }

    update(); // triggers UI refresh if using GetBuilder
  }
}

