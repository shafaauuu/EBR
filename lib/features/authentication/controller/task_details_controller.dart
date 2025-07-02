import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:oji_1/common/api.dart';
import '../models/material_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import './task_controller.dart';

class TaskDetailsController extends GetxController {
  var selectedMaterialCode = ''.obs;
  var selectedMaterialDisplay = ''.obs;
  var requiredQuantity = ''.obs;
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;
  var materials = <MaterialModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  Map<String, String?> selectedValues = {};
  
  // For shift management
  var selectedGroup = ''.obs;
  var selectedPerson = ''.obs;
  var availableGroups = <String>[].obs;
  var isLoadingGroups = false.obs;
  var isLoadingUsers = false.obs;
  
  // People in each group (will be populated from API)
  RxList<Map<String, dynamic>> groupPeople = <Map<String, dynamic>>[].obs;

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
  
  Future<bool> showShiftInputDialog() async {
    final storage = GetStorage();
    final firstName = storage.read("first_name") ?? "First Name";
    final inisial = storage.read("inisial") ?? "-";
    final group = storage.read("group") ?? "-";
    final taskId = storage.read("current_task_id") ?? 0;
    
    // Reset selections
    selectedGroup.value = '';
    selectedPerson.value = '';
    
    // Fetch shift groups
    fetchShiftGroups();
    
    bool transferred = false;
    
    await Get.dialog(
      AlertDialog(
        title: const Text("Shift Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Obx(() => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current user info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current User", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text("Name: $firstName"),
                    Text("Inisial: $inisial"),
                    Text("Group: $group"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Transfer to:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Group dropdown
              isLoadingGroups.value 
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Group',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedGroup.value.isEmpty ? null : selectedGroup.value,
                    items: availableGroups.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedGroup.value = newValue;
                        selectedPerson.value = ''; // Reset person selection
                        fetchUsersByShiftGroup(newValue);
                      }
                    },
                  ),
              
              const SizedBox(height: 16),
              
              // Person dropdown (only shown if group is selected)
              selectedGroup.value.isNotEmpty
                ? isLoadingUsers.value 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Person',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedPerson.value.isEmpty ? null : selectedPerson.value,
                      items: groupPeople.map((person) {
                        return DropdownMenuItem<String>(
                          value: person['nik'],
                          child: Text("${person['first_name'] ?? ''} ${person['last_name'] ?? ''} (${person['inisial'] ?? '-'})"),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedPerson.value = newValue;
                        }
                      },
                    )
                : const SizedBox.shrink()
            ],
          ),
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          Obx(() => ElevatedButton(
            onPressed: selectedGroup.value.isNotEmpty && selectedPerson.value.isNotEmpty
              ? () async {
                  // Get the current task ID
                  final taskId = storage.read("current_task_id");
                  if (taskId != null) {
                    // Show loading indicator
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false,
                      name: 'loadingDialog',
                    );
                    
                    bool result = await transferTaskToShift([taskId], selectedGroup.value, selectedPerson.value);
                    
                    // Close loading dialog
                    Get.back(closeOverlays: true);
                    
                    if (result) {
                      transferred = true;
                      
                      // Show success alert immediately
                      await ArtSweetAlert.show(
                        context: Get.context!,
                        artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.success,
                          title: "Success",
                          text: "Task transferred successfully"
                        )
                      );
                      
                      // Close the transfer dialog with result
                      Get.back(result: true);
                    } else {
                      // Show error alert
                      await ArtSweetAlert.show(
                        context: Get.context!,
                        artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.danger,
                          title: "Error",
                          text: "Failed to transfer task"
                        )
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Error',
                      'No task selected for transfer',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    Get.back(result: false);
                  }
                }
              : null,
            child: const Text("Transfer"),
          )),
        ],
      ),
    );
    
    return transferred;
  }
  
  // Fetch available shift groups
  Future<void> fetchShiftGroups() async {
    isLoadingGroups.value = true;
    try {
      final response = await Api.get("shift-groups");
      if (response != null) {
        // The API returns a direct array of shift groups
        availableGroups.value = List<String>.from(response);
        print('Fetched shift groups: ${availableGroups.value}');
      } else {
        // Fallback to default groups if API returns null
        availableGroups.value = ['A', 'B', 'C', 'D'];
      }
    } catch (e) {
      print("Error fetching shift groups: $e");
      // Fallback to default groups if API fails
      availableGroups.value = ['A', 'B', 'C', 'D'];
    } finally {
      isLoadingGroups.value = false;
    }
  }
  
  // Fetch users by shift group
Future<void> fetchUsersByShiftGroup(String shiftGroup) async {
  isLoadingUsers.value = true;
  groupPeople.clear();

  try {
    print('Fetching users for shift group: $shiftGroup');

    final response = await Api.post("users/by-shift-group", {
      'group': shiftGroup  // Changed from 'shift_group' to 'group' to match API
    });

    print('Users response: $response');

    if (response != null) {
      // Check if response is a direct array or has a 'users' key
      if (response is List) {
        groupPeople.value = List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response['users'] != null) {
        groupPeople.value = List<Map<String, dynamic>>.from(response['users']);
      }
      print('Fetched users for shift group $shiftGroup: ${groupPeople.length} users');
    }
  } catch (e) {
    print("Error fetching users by shift group: $e");
    Get.snackbar(
      'Error',
      'Failed to load users for this shift group',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoadingUsers.value = false;
  }
}

  // Transfer tasks to shift
Future<bool> transferTaskToShift(List<dynamic> taskIds, String shiftGroup, String assignedTo) async {
  try {
    print('Transferring tasks: $taskIds to shift group: $shiftGroup, assigned to: $assignedTo');

    // Ensure taskIds is properly formatted
    List<dynamic> formattedTaskIds = taskIds.map((id) => int.tryParse(id.toString()) ?? id).toList();
    print('Formatted task IDs: $formattedTaskIds');

    final response = await Api.post("tasks/transfer-to-shift", {
      'tasks': formattedTaskIds,
      'group': shiftGroup,
      'assigned_to': assignedTo
    });

    print('Transfer response: $response');

    // Handle different response formats
    String message = 'Task transferred successfully';
    if (response != null) {
      if (response is Map && response['message'] != null) {
        message = response['message'];
      }
    }

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    return true;
  } catch (e) {
    print("Error transferring tasks: $e");
    Get.snackbar(
      'Error',
      'Failed to transfer task: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }
}
  // Observable BRM List
  RxList<String> brmList = <String>[].obs;

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

  // Selected BRM
  RxString selectedBRM = ''.obs;
  RxBool isBrmLoading = false.obs;

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
    isBrmLoading.value = true;
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
    } finally {
      isBrmLoading.value = false;
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
    isBrmLoading.value = true;
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
    } finally {
      isBrmLoading.value = false;
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
