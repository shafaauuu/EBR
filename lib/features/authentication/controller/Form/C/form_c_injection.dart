import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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

  FormCInjectionController(this.task) : brmNo = task.brmNo ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchChildMaterials();
    fetchExistingData(); // Add this line to fetch existing data

    // Initialize radio selections and note controllers
    ['1', '2', '3'].forEach((id) {
      radioSelections[id] = '';
      noteControllers[id] = TextEditingController();
    });
  }

  @override
  void onClose() {
    // Dispose all controllers
    batchControllers.values.forEach((controller) => controller.dispose());
    qtyControllers.values.forEach((controller) => controller.dispose());
    noteControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }

  Future<void> fetchChildMaterials() async {
    try {
      isLoading.value = true;
      print("Starting to fetch child materials for Injection");
      
      final response = await Api.get('tasks/${task.id}/child-materials-injection');
      print("Child materials API response received: ${response != null ? 'Success' : 'Null response'}");
      
      if (response is List) {
        print("Response is a List with ${response.length} items");
        
        // Convert each item in the response to a Map<String, dynamic>
        List<Map<String, dynamic>> materialsList = [];
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            // Generate a unique ID for each material if not present
            if (!item.containsKey('id')) {
              item['id'] = item['material_code'] ?? item['id_mat']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            }
            materialsList.add(item);
          }
        }
        
        materials.value = materialsList;
        print("Processed ${materials.length} materials from API response");

        // Initialize controllers for materials
        for (var material in materials) {
          final id = material['id']?.toString() ?? '';
          if (id.isNotEmpty) {
            batchControllers.putIfAbsent(id, () => TextEditingController());
            qtyControllers.putIfAbsent(id, () => TextEditingController());
            selectedMaterials[id] = material; // Auto-select all materials
          }
        }
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
                    'id_mat': materialId,
                    ...entry,
                  });
                }
              }
            }
          });

          existingMaterials.assignAll(flattenedMaterials);

          // Pre-populate form fields with existing data if available
          if (existingFormData.value != null) {
            final data = existingFormData.value!;

            // Set radio selections based on existing data
            radioSelections['1'] = data['sesuai_picklist'] == true ? 'Ya' : 'Tidak';
            radioSelections['2'] = data['sesuai_bets'] == true ? 'Ya' : 'Tidak';
            radioSelections['3'] = data['mat_lengkap'] == true ? 'Ya' : 'Tidak';

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
        final materialId = entry.key;
        final material = entry.value;
        return {
          'id_mat': material['id_mat'] ?? material['id'], // Use id_mat if available, otherwise fall back to id
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