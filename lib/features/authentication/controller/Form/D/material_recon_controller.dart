import 'package:get/get.dart';
import 'package:oji_1/common/api.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import 'dart:convert';

class MaterialReconController extends GetxController {
  var isLoading = false.obs;
  final Task task;
  final String selectedMaterialCode;
  
  // Observable lists and maps
  final materials = <Map<String, dynamic>>[].obs;
  final selectedMaterials = <String, Map<String, dynamic>>{}.obs;
  final existingMaterials = <Map<String, dynamic>>[].obs;
  
  // Controllers for form fields
  final Map<String, TextEditingController> jmlAwalControllers = {};
  final Map<String, TextEditingController> jmlSpbtControllers = {};
  final Map<String, TextEditingController> jmlRejectControllers = {};
  final Map<String, TextEditingController> jmlPakaiControllers = {};
  final Map<String, TextEditingController> jmlKarantinaControllers = {};
  final Map<String, TextEditingController> sisaControllers = {};
  final Map<String, TextEditingController> jmlMusnahControllers = {};
  final Map<String, TextEditingController> jmlKembaliControllers = {};
  
  MaterialReconController(this.task, this.selectedMaterialCode);
  
  @override
  void onInit() {
    super.onInit();
    fetchExistingData();
  }
  
  @override
  void onClose() {
    // Dispose all controllers
    jmlAwalControllers.values.forEach((controller) => controller.dispose());
    jmlSpbtControllers.values.forEach((controller) => controller.dispose());
    jmlRejectControllers.values.forEach((controller) => controller.dispose());
    jmlPakaiControllers.values.forEach((controller) => controller.dispose());
    jmlKarantinaControllers.values.forEach((controller) => controller.dispose());
    sisaControllers.values.forEach((controller) => controller.dispose());
    jmlMusnahControllers.values.forEach((controller) => controller.dispose());
    jmlKembaliControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }
  
  Future<void> fetchChildMaterials() async {
    try {
      isLoading.value = true;
      print("Starting to fetch child materials for Material Reconciliation");
      
      // Use the correct endpoint from your Laravel routes
      final endpoint = 'form-d/tasks/${task.id}/child-materials/${selectedMaterialCode}';
      
      print("Using API endpoint: $endpoint for task ID: ${task.id}");
      final response = await Api.get(endpoint);
      print("Child materials API response received: ${response != null ? 'Success' : 'Null response'}");
      
      // Debug the response structure
      print("Response type: ${response.runtimeType}");
      print("Raw response: $response");
      
      // Handle different response formats
      List<Map<String, dynamic>> materialsList = [];
      
      if (response is Map<String, dynamic>) {
        // Format: {"data": [...]} or direct object
        print("Response is a Map");
        if (response.containsKey('data')) {
          final responseData = response['data'];
          
          if (responseData is List) {
            print("Response data is a List with ${responseData.length} items");
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                materialsList.add(item);
              }
            }
          }
        } else {
          // Direct object response
          materialsList.add(response);
        }
      } else if (response is List) {
        // Format: [...]
        print("Response is a direct List with ${response.length} items");
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            materialsList.add(item);
          }
        }
      } else {
        print("Response is not a List or Map: ${response.runtimeType}");
        materials.value = []; // Set empty list to avoid null issues
      }
      
      print("Processed ${materialsList.length} materials from API response");
      
      // Process materials and initialize controllers
      if (materialsList.isNotEmpty) {
        for (var item in materialsList) {
          // Use id_bom as the unique identifier for each material
          final String materialId = item['id_bom']?.toString() ?? '';
          if (materialId.isNotEmpty) {
            // Initialize controllers for this material
            jmlAwalControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlSpbtControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlRejectControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlPakaiControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlKarantinaControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            sisaControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlMusnahControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            jmlKembaliControllers.putIfAbsent(materialId, () => TextEditingController(text: '0'));
            
            // Auto-select all materials using id_bom as key
            selectedMaterials[materialId] = item;
          }
        }
        
        // Update the materials observable list
        materials.value = materialsList;
        print("Updated materials.value with ${materials.length} items");
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
      // Use the correct endpoint from your Laravel routes
      final endpoint = 'form-d/material-recon/${task.id}?is_task_id=true';
      final response = await Api.get(endpoint);
      
      if (response != null && response['data'] != null) {
        final materialsData = response['data'] as List;
        
        // Process materials data
        if (materialsData.isNotEmpty) {
          final flattenedMaterials = <Map<String, dynamic>>[];
          
          for (var material in materialsData) {
            if (material is Map<String, dynamic>) {
              final String materialId = material['id_bom']?.toString() ?? '';
              if (materialId.isNotEmpty) {
                flattenedMaterials.add(material);
                
                // Pre-populate form fields with existing data
                jmlAwalControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_awal']?.toString() ?? '0'));
                jmlSpbtControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_spbt']?.toString() ?? '0'));
                jmlRejectControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_reject']?.toString() ?? '0'));
                jmlPakaiControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_pakai']?.toString() ?? '0'));
                jmlKarantinaControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_karantina']?.toString() ?? '0'));
                sisaControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['sisa']?.toString() ?? '0'));
                jmlMusnahControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_musnah']?.toString() ?? '0'));
                jmlKembaliControllers.putIfAbsent(materialId, () => 
                    TextEditingController(text: material['jml_kembali']?.toString() ?? '0'));
              }
            }
          }
          
          existingMaterials.assignAll(flattenedMaterials);
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
    // Validate materials
    for (var entry in selectedMaterials.entries) {
      final materialId = entry.key;
      
      // Check if jml_awal is filled
      final jmlAwalStr = jmlAwalControllers[materialId]?.text ?? '';
      final jmlAwal = int.tryParse(jmlAwalStr) ?? -1;
      
      if (jmlAwal < 0) {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Perhatian",
            text: "Harap isi jumlah awal yang valid untuk semua material"
          )
        );
        return false;
      }
    }
    
    return true;
  }
  
  Future<bool> submitForm() async {
    // First validate the form
    if (!validateForm()) {
      return false;
    }
    
    try {
      isLoading.value = true;
      
      // Prepare materials data for submission
      final List<Map<String, dynamic>> materialsData = [];
      
      for (var entry in selectedMaterials.entries) {
        final materialId = entry.key;
        final material = entry.value;
        
        // Get the child material data
        final childMaterial = material['child_material'] ?? material['childMaterial'];
        if (childMaterial == null) continue;
        
        // Parse values from controllers, defaulting to 0 if invalid
        final jmlAwal = int.tryParse(jmlAwalControllers[materialId]?.text ?? '') ?? 0;
        final jmlSpbt = int.tryParse(jmlSpbtControllers[materialId]?.text ?? '') ?? 0;
        final jmlReject = int.tryParse(jmlRejectControllers[materialId]?.text ?? '') ?? 0;
        final jmlPakai = int.tryParse(jmlPakaiControllers[materialId]?.text ?? '') ?? 0;
        final jmlKarantina = int.tryParse(jmlKarantinaControllers[materialId]?.text ?? '') ?? 0;
        final sisa = int.tryParse(sisaControllers[materialId]?.text ?? '') ?? 0;
        final jmlMusnah = int.tryParse(jmlMusnahControllers[materialId]?.text ?? '') ?? 0;
        final jmlKembali = int.tryParse(jmlKembaliControllers[materialId]?.text ?? '') ?? 0;
        
        materialsData.add({
          'id_mat': childMaterial['id_mat'] ?? '',
          'id_bom': materialId,
          'material_code': childMaterial['material_code'] ?? '',
          'material_uom': childMaterial['uom'] ?? 'PCS', // Default to 'PCS' if uom is not available
          'jml_awal': jmlAwal,
          'jml_spbt': jmlSpbt,
          'jml_reject': jmlReject,
          'jml_pakai': jmlPakai,
          'jml_karantina': jmlKarantina,
          'sisa': sisa,
          'jml_musnah': jmlMusnah,
          'jml_kembali': jmlKembali,
        });
      }
      
      // Prepare the data for submission
      final dataToSubmit = {
        'code_task': task.code,
        'task_id': task.id,
        'materials': materialsData,
      };
      
      print('Submitting material reconciliation data: ${json.encode(dataToSubmit)}');
      
      // Submit the data to the correct endpoint
      final response = await Api.post('form-d/material-recon', dataToSubmit);
      
      if (response != null) {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Berhasil",
            text: "Material reconciliation berhasil disimpan"
          )
        );
        return true;
      } else {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Error",
            text: "Gagal menyimpan data. Silakan coba lagi."
          )
        );
        return false;
      }
    } catch (e) {
      print('Error submitting material reconciliation: $e');
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