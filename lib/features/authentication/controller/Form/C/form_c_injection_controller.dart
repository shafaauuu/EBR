import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oji_1/common/api.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormCInjectionController extends GetxController {
  final Task task;
  final String brmNo;
  final isLoading = false.obs;
  final materials = <Map<String, dynamic>>[].obs;
  final selectedMaterials = <String, Map<String, dynamic>>{}.obs;
  final formData = <String, dynamic>{}.obs;

  // Observable to store existing form data from backend
  final existingFormData = Rx<Map<String, dynamic>?>(null);
  final existingMaterials = <Map<String, dynamic>>[].obs;

  // Controllers for form fields
  final Map<String, TextEditingController> batchControllers = {};
  final Map<String, TextEditingController> qtyControllers = {};
  final Map<String, TextEditingController> noteControllers = {};
  final Map<String, String> radioSelections = {};
  final String? selectedMaterialCode;
  FormCInjectionController(this.task, this.selectedMaterialCode) : brmNo = task.brmNo ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchChildMaterials();
    fetchExistingData(); // Add this line to fetch existing data

    // Initialize radio selections and note controllers
    for (var id in ['1', '2', '3']) {
      radioSelections[id] = '';
      noteControllers[id] = TextEditingController();
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var controller in batchControllers.values) {
      controller.dispose();
    }
    for (var controller in qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in noteControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> fetchChildMaterials() async {
    try {
      isLoading.value = true;
      print("Starting to fetch child materials for Injection");
      
      final response = await Api.get('tasks/${task.id}/child-materials-injection/$selectedMaterialCode');
      print("Child materials API response received: ${response != null ? 'Success' : 'Null response'}");

      if (response is List) {
        print("Response is a List with ${response.length} items");

        // Convert each item in the response to a Map<String, dynamic>
        List<Map<String, dynamic>> materialsList = [];
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            // Use id_bom as the unique identifier for each material
            final String materialId = item['id_bom']?.toString() ?? '';
            if (materialId.isNotEmpty) {
              materialsList.add(item);
              // var lastData = selectedMaterials[materialId];

              // Initialize controllers for this material
              batchControllers.putIfAbsent(materialId, () => TextEditingController(text: ''));
              qtyControllers.putIfAbsent(materialId, () => TextEditingController());

              // Auto-select all materials using id_bom as key
              selectedMaterials[materialId] = item;
            }
          }
        }

        materials.value = materialsList;
        print("Processed ${materials.length} materials from API response");
      } else {
        print("Response is not a List: ${response.runtimeType}");
        materials.value = []; // Set empty list to avoid null issues
      }
    } catch (e) {
      print("Error fetching child materials: $e");
      materials.value = [];

      if (Get.context != null) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error",
                text: "Failed to load materials: $e"
            )
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExistingData() async {
    try {
      isLoading.value = true;
      final response = await Api.get('form-c-injection/${task.id}');

      if (response != null) {
        existingFormData.value = response['common_data'];

        // Debug: Print the data types of boolean fields
        if (response['common_data'] != null) {
          final data = response['common_data'];
          print('DEBUG - Data types:');
          print('sesuai_picklist: ${data['sesuai_picklist']} (${data['sesuai_picklist'].runtimeType})');
          print('sesuai_bets: ${data['sesuai_bets']} (${data['sesuai_bets'].runtimeType})');
          print('mat_lengkap: ${data['mat_lengkap']} (${data['mat_lengkap'].runtimeType})');
        }

        // Process materials data
        if (response['materials'] != null) {
          final materialsMap = response['materials'] as Map<String, dynamic>;

          // Flatten the nested structure for easier processing
          final flattenedMaterials = <Map<String, dynamic>>[];

          materialsMap.forEach((materialId, materialEntries) {
            if (materialEntries is List) {
              for (var entry in materialEntries) {
                if (entry is Map<String, dynamic>) {
                  flattenedMaterials.add({
                    'id_bom': materialId, // Use id_bom consistently
                    ...entry,
                  });
                }
              }
            }
          });

          print(flattenedMaterials);

          existingMaterials.assignAll(flattenedMaterials);

          // Pre-populate form fields with existing data
          materialsMap.forEach((materialId, value) {
            var data = value is List ? value.first : {};
            batchControllers.putIfAbsent(materialId, () => TextEditingController(text: data['batch_no'] ?? ''));
            qtyControllers.putIfAbsent(materialId, () => TextEditingController(text: data['actual_qty']?.toString() ?? ''));
          });

          // Set radio selections based on existing data
          if (existingFormData.value != null) {
            final data = existingFormData.value!;

            // Set note controllers
            noteControllers['1']?.text = data['remarks_picklist'] ?? '';
            noteControllers['2']?.text = data['remarks_bets'] ?? '';
            noteControllers['3']?.text = data['remarks_mat'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error fetching existing data: $e');
      // Don't show error alert here as it's not critical
    } finally {
      isLoading.value = false;
    }
    fetchChildMaterials();
  }

  bool validateForm() {
    // Validate radio selections
    for (var id in radioSelections.keys) {
      if (radioSelections[id]?.isEmpty ?? true) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Perhatian",
                text: "Harap jawab semua kriteria"
            )
        );
        return false;
      }

      // Validate notes for "Tidak" answers
      if (radioSelections[id] == "Tidak" &&
          (noteControllers[id]?.text.isEmpty ?? true)) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Perhatian",
                text: "Harap isi catatan untuk kriteria yang dipilih \"Tidak\""
            )
        );
        return false;
      }
    }

    // Validate materials
    for (var entry in selectedMaterials.entries) {
      final materialId = entry.key;
      final batchNo = batchControllers[materialId]?.text ?? '';
      final qtyStr = qtyControllers[materialId]?.text ?? '';
      final qty = int.tryParse(qtyStr) ?? 0;

      if (batchNo.isEmpty) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Perhatian",
                text: "Harap isi nomor batch untuk semua material"
            )
        );
        return false;
      }

      if (qty <= 0) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Perhatian",
                text: "Harap isi kuantitas yang valid untuk semua material"
            )
        );
        return false;
      }
    }

    return true;
  }

  Future<bool> submitForm(Map<String, dynamic> formData) async {
    try {
      isLoading.value = true;

      // Prepare materials data - format to match backend API expectations
      final materialsData = selectedMaterials.entries.map((entry) {
        final materialId = entry.key; // This is now id_bom
        final material = entry.value;

        return {
          'id_mat': material['id_mat'] ?? '',
          'id_bom': materialId, // Use the key directly as id_bom
          'batch_no': batchControllers[materialId]?.text ?? '',
          'actual_qty': int.tryParse(qtyControllers[materialId]?.text ?? '0') ?? 0,
        };
      }).toList();

      // Prepare the data for submission according to backend API structure
      final dataToSubmit = {
        'code_task': task.code,
        'id_brm': task.brmNo ?? '',
        'task_id': task.id,
        'sesuai_picklist': formData['sesuai_picklist'],
        'remarks_picklist': formData['remarks_picklist'] ?? '',
        'sesuai_bets': formData['sesuai_bets'],
        'remarks_bets': formData['remarks_bets'] ?? '',
        'mat_lengkap': formData['mat_lengkap'],
        'remarks_mat': formData['remarks_mat'] ?? '',
        'materials': materialsData,
      };

      print('Submitting data: ${json.encode(dataToSubmit)}');

      // Submit the data
      final response = await Api.post('form-c-injection', dataToSubmit);

      if (response != null) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Berhasil",
                text: "Form C berhasil disimpan"
            )
        );
        return true;
      } else {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error",
                text: "Gagal menyimpan form. Silakan coba lagi."
            )
        );
        return false;
      }
    } catch (e) {
      print('Error submitting form: $e');
      ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Terjadi kesalahan saat mengirim data: $e"
          )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}