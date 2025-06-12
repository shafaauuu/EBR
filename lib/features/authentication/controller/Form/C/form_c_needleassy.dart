import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oji_1/common/api.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormCNeedleAssyController extends GetxController {
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

  FormCNeedleAssyController(this.task) : brmNo = task.brmNo ?? '';

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    
    // Initialize radio selections and note controllers first
    ['1', '2', '3'].forEach((id) {
      radioSelections[id] = '';
      noteControllers[id] = TextEditingController();
    });
    
    // Use Future.wait with catchError to ensure loading state is reset even if both API calls fail
    Future.wait([
      fetchChildMaterials().catchError((e) {
        print("Child materials fetch failed: $e");
        return null; // Return null to allow Future.wait to continue
      }),
      fetchExistingData().catchError((e) {
        print("Existing data fetch failed: $e");
        return null; // Return null to allow Future.wait to continue
      })
    ]).then((_) {
      // Ensure loading is set to false when both calls complete
      isLoading.value = false;
      print("Both API calls completed, loading set to false");
    }).catchError((error) {
      print("Error during initialization: $error");
      isLoading.value = false;
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print("API calls timed out after 10 seconds");
        isLoading.value = false;
        return null;
      }
    );
  }

  @override
  void onClose() {
    batchControllers.values.forEach((controller) => controller.dispose());
    qtyControllers.values.forEach((controller) => controller.dispose());
    noteControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }

  Future<void> fetchChildMaterials() async {
    try {
      print("Starting to fetch child materials for Needle Assy");

      // Try the new endpoint first
      try {
        final response = await Api.get('tasks/${task.id}/child-materials-needle-assy')
            .timeout(const Duration(seconds: 5));

        print("Child materials API response received from new endpoint: ${response != null ? 'Success' : 'Null response'}");

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
          return; // Exit early if successful
        } else {
          print("Response from new endpoint is not a List: ${response.runtimeType}");
        }
      } catch (e) {
        print("Error with new endpoint, trying fallback: $e");
      }

      // Fallback to the original endpoint if the new one fails
      print("Trying fallback endpoint: child-materials");
      final fallbackResponse = await Api.get('tasks/${task.id}/child-materials')
          .timeout(const Duration(seconds: 5));

      print("Child materials API fallback response received: ${fallbackResponse != null ? 'Success' : 'Null response'}");

      if (fallbackResponse is List) {
        print("Fallback response is a List with ${fallbackResponse.length} items");
        // Convert each item in the response to a Map<String, dynamic>
        List<Map<String, dynamic>> materialsList = [];
        for (var item in fallbackResponse) {
          if (item is Map<String, dynamic>) {
            // Generate a unique ID for each material if not present
            if (!item.containsKey('id')) {
              item['id'] = item['material_code'] ?? item['id_mat']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            }
            materialsList.add(item);
          }
        }
        
        materials.value = materialsList;
        print("Processed ${materials.length} materials from fallback API response");

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
        print("Fallback response is not a List: ${fallbackResponse.runtimeType}");
        materials.value = []; // Set empty list to avoid null issues
      }
    } catch (e) {
      print("Error fetching child materials (all attempts failed): $e");
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
    }
  }

  Future<void> fetchExistingData() async {
    try {
      print("Starting to fetch existing data for Needle Assy");

      // Try the specific endpoint first
      try {
        final response = await Api.get('form-c-needle-assy/${task.id}')
            .timeout(const Duration(seconds: 5));

        print("Existing data API response received: ${response != null ? 'Success' : 'Null response'}");

        if (response != null) {
          if (response['common_data'] != null) {
            existingFormData.value = response['common_data'];
            print("Common data: ${existingFormData.value != null ? 'Found' : 'Not found'}");
          } else {
            print("No common_data found in response");
            existingFormData.value = null;
          }

          if (response['materials'] != null) {
            print("Materials data found in response");
            final flattenedMaterials = <Map<String, dynamic>>[];

            // Check if materials is a Map or a List
            if (response['materials'] is Map<String, dynamic>) {
              print("Materials is a Map");
              final materialsMap = response['materials'] as Map<String, dynamic>;

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
            } else if (response['materials'] is List) {
              print("Materials is a List with ${(response['materials'] as List).length} items");
              final materialsList = response['materials'] as List;

              for (var entry in materialsList) {
                if (entry is Map<String, dynamic>) {
                  flattenedMaterials.add(entry);
                }
              }
            } else {
              print("Materials is neither a Map nor a List: ${response['materials'].runtimeType}");
            }

            print("Flattened ${flattenedMaterials.length} materials");
            existingMaterials.assignAll(flattenedMaterials);

            if (existingFormData.value != null) {
              final data = existingFormData.value!;
              print("Pre-populating form fields with existing data");

              radioSelections['1'] = data['sesuai_picklist'] == true ? 'Ya' : 'Tidak';
              radioSelections['2'] = data['sesuai_bets'] == true ? 'Ya' : 'Tidak';
              radioSelections['3'] = data['mat_lengkap'] == true ? 'Ya' : 'Tidak';

              noteControllers['1']?.text = data['remarks_picklist'] ?? '';
              noteControllers['2']?.text = data['remarks_bets'] ?? '';
              noteControllers['3']?.text = data['remarks_mat'] ?? '';
            }
          } else {
            print("No materials data found in response");
            existingMaterials.clear();
          }

          return; // Exit early if successful
        }
      } catch (e) {
        print("Error with specific endpoint: $e");
        // Continue to fallback
      }

      // If we get here, the specific endpoint failed, so we'll try a generic one
      print("Trying generic form-c endpoint");
      try {
        final fallbackResponse = await Api.get('form-c/${task.id}')
            .timeout(const Duration(seconds: 5));

        print("Generic form-c API response received: ${fallbackResponse != null ? 'Success' : 'Null response'}");

        // Process the fallback response similar to above...
        if (fallbackResponse != null) {
          if (fallbackResponse['common_data'] != null) {
            existingFormData.value = fallbackResponse['common_data'];
          }

          // Process materials if available...
          if (fallbackResponse['materials'] != null) {
            // Similar processing as above
          }
        }
      } catch (e) {
        print("Error with generic endpoint: $e");
        // Both attempts failed, continue to the catch block
        throw e;
      }
    } catch (e) {
      print('Error fetching existing data (all attempts failed): $e');
      existingFormData.value = null;
      existingMaterials.clear();
    }
  }

  bool validateForm() {
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

      final materialsData = selectedMaterials.entries.map((entry) {
        final materialId = entry.key;
        final material = entry.value;
        return {
          'id_mat': material['id_mat'] ?? material['id'], // Use id_mat if available, otherwise fall back to id
          'batch_no': batchControllers[materialId]?.text ?? '',
          'actual_qty': int.tryParse(qtyControllers[materialId]?.text ?? '0') ?? 0,
        };
      }).toList();

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

      final response = await Api.post('form-c-needle-assy', dataToSubmit);

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