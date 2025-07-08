import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oji_1/common/api.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormDAssySyringeController extends GetxController {
  var isLoading = false.obs;
  var machineTypes = <String>[].obs;
  var selectedMachineType = ''.obs;
  var displayData = {}.obs;
  var machineId = 0.obs;
  var brmNo = ''.obs;
  var taskId = 0.obs;
  var machineList = <Map<String, dynamic>>[].obs;
  var machineDisplayList = <Map<String, dynamic>>[].obs;
  var filteredMachineDisplays = <Map<String, dynamic>>[].obs;
  var parameterControllers = <String, TextEditingController>{}.obs;

  // Form fields for Assy
  var printMatchSpeed = ''.obs;
  var assyMatchSpeed = ''.obs;
  var loadBarrel = false.obs;
  var loadPlunger = false.obs;
  var loadGasket = false.obs;
  var actualRunning = ''.obs;
  var runAwal = ''.obs;
  var defect = ''.obs;
  var goodsOk = ''.obs;
  var goodsReject = ''.obs;
  
  // Form fields for Blister
  var materialType = ''.obs;
  var formingTime = ''.obs;
  var formingTemperature = ''.obs;
  var formingPressure = ''.obs;
  var sealingTemperature = ''.obs;
  var sealingPressure = ''.obs;
  var sealingTime = ''.obs;
  var cycleTime = ''.obs;
  var mfgDate = ''.obs;
  var expDate = ''.obs;
  var needleSize = ''.obs;
  var nie = ''.obs;
  
  // Form fields for SGP
  var temp1 = ''.obs;
  var temp2 = ''.obs;
  var temp3 = ''.obs;
  var temp4 = ''.obs;
  var loadCap = false.obs;
  var loadHub = false.obs;
  var loadNeedle = false.obs;
  var hasilEpoxy = false.obs;
  var pressureActual = ''.obs;
  var pressureStatus = false.obs;
  var lowEpoxy1 = false.obs;
  var lowEpoxy2 = false.obs;
  var lowEpoxy3 = false.obs;
  var hubCanula1 = false.obs;
  var hubCanula2 = false.obs;
  var hubCanula3 = false.obs;
  var excEpoxy1 = false.obs;
  var excEpoxy2 = false.obs;
  var excEpoxy3 = false.obs;
  var needleTumpul1 = false.obs;
  var needleTumpul2 = false.obs;
  var needleTumpul3 = false.obs;
  var needleBalik1 = false.obs;
  var needleBalik2 = false.obs;
  var needleBalik3 = false.obs;
  var needleTersumbat1 = false.obs;
  var needleTersumbat2 = false.obs;
  var needleTersumbat3 = false.obs;
  var moldTemperature = ''.obs;
  var injectionPressure = ''.obs;
  var injectionSpeed = ''.obs;
  var holdingPressure = ''.obs;
  var holdingTime = ''.obs;
  var coolingTime = ''.obs;

  // Status checkboxes and actual values for machine parameters
  var statusChecks = <bool>[].obs;
  var actualValues = <String>[].obs;

  // Get machines for a task
  Future<void> getMachinesByTask(String brmNo, int taskId) async {
    isLoading.value = true;
    try {
      // Store the BRM number and task ID for later use
      this.brmNo.value = brmNo;
      this.taskId.value = taskId;
      
      List<Map<String, dynamic>> allMachineDisplays = [];

      
      // Try assy machines first
      final assyResponse = await Api.get('display-machine-assy');
      if (assyResponse != null) {
        List<dynamic> assyDisplays = assyResponse;
        for (var item in assyDisplays) {
          item['machine_type'] = 'assy';
        }
        allMachineDisplays.addAll(assyDisplays.cast<Map<String, dynamic>>());
      }
      
      // Try FCS-SHI machines
      final fcsShiResponse = await Api.get('display-machine-fcs-shi');
      if (fcsShiResponse != null) {
        List<dynamic> fcsShiDisplays = fcsShiResponse;
        for (var item in fcsShiDisplays) {
          item['machine_type'] = 'fcs_shi';
        }
        allMachineDisplays.addAll(fcsShiDisplays.cast<Map<String, dynamic>>());
      }
      
      // Try FCS machines
      final fcsResponse = await Api.get('display-machine-fcs');
      if (fcsResponse != null) {
        List<dynamic> fcsDisplays = fcsResponse;
        for (var item in fcsDisplays) {
          item['machine_type'] = 'fcs';
        }
        allMachineDisplays.addAll(fcsDisplays.cast<Map<String, dynamic>>());
      }
      
      // Try SHI 1 machines
      final shi1Response = await Api.get('display-machine-shi-1');
      if (shi1Response != null) {
        List<dynamic> shi1Displays = shi1Response;
        for (var item in shi1Displays) {
          item['machine_type'] = 'shi_1';
        }
        allMachineDisplays.addAll(shi1Displays.cast<Map<String, dynamic>>());
      }
      
      // Try SHI 2 machines
      final shi2Response = await Api.get('display-machine-shi-2');
      if (shi2Response != null) {
        List<dynamic> shi2Displays = shi2Response;
        for (var item in shi2Displays) {
          item['machine_type'] = 'shi_2';
        }
        allMachineDisplays.addAll(shi2Displays.cast<Map<String, dynamic>>());
      }
      
      // Try Blister machines
      final blisterResponse = await Api.get('display-machine-blister');
      if (blisterResponse != null) {
        List<dynamic> blisterDisplays = blisterResponse;
        for (var item in blisterDisplays) {
          item['machine_type'] = 'blister';
        }
        allMachineDisplays.addAll(blisterDisplays.cast<Map<String, dynamic>>());
      }
      
      // Try SGP machines
      final sgpResponse = await Api.get('display-machine-sgp');
      if (sgpResponse != null) {
        List<dynamic> sgpDisplays = sgpResponse;
        for (var item in sgpDisplays) {
          item['machine_type'] = 'sgp';
        }
        allMachineDisplays.addAll(sgpDisplays.cast<Map<String, dynamic>>());
      }
      
      // Store all machine displays
      machineDisplayList.assignAll(allMachineDisplays);
      
      // Try to get machines specifically by BRM number for more accurate filtering
      await getMachinesByBrm(brmNo);
      
      // Filter machines by BRM number
      List<Map<String, dynamic>> filteredDisplays = allMachineDisplays
          .where((item) => item['brm_no'] == brmNo)
          .toList();
      
      // Store filtered displays for UI access
      filteredMachineDisplays.assignAll(filteredDisplays);
      
      if (filteredDisplays.isNotEmpty) {
        // Extract unique machines from the filtered display data
        Set<int> uniqueMachineIds = {};
        List<Map<String, dynamic>> uniqueMachines = [];
        
        for (var item in filteredDisplays) {
          if (item['machine'] != null && !uniqueMachineIds.contains(item['machine']['id_machine'])) {
            uniqueMachineIds.add(item['machine']['id_machine']);
            uniqueMachines.add({
              'id_machine': item['machine']['id_machine'],
              'machine_name': item['machine']['machine_name'],
              'machine_code': item['machine']['machine_code'],
              'machine_type': item['machine_type'] ?? 'non', // Default to 'non' if not specified
            });
          }
        }
        
        machineList.assignAll(uniqueMachines);
        
        // Determine machine type based on the first filtered display
        if (filteredDisplays.first['form_d_display'] != null) {
          // Check which endpoint returned this machine
          int machineId = filteredDisplays.first['machine']['id_machine'];
          
          if (assyResponse != null && 
              assyResponse.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'assy';
          } else if (fcsShiResponse != null &&
              fcsShiResponse.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'fcs_shi';
          } else if (fcsResponse != null &&
              fcsResponse.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'fcs';
          } else if (shi1Response != null &&
              shi1Response.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'shi_1';
          } else if (shi2Response != null &&
              shi2Response.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'shi_2';
          } else if (blisterResponse != null &&
              blisterResponse.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'blister';
          } else if (sgpResponse != null &&
              sgpResponse.any((item) => 
                item['machine'] != null && 
                item['machine']['id_machine'] == machineId)) {
            selectedMachineType.value = 'sgp';
          } else {
            selectedMachineType.value = 'assy'; // Default
          }
        } else {
          selectedMachineType.value = 'assy'; // Default
        }
      } else {
        // If no machines found for this BRM, set empty machine list with fallback message
        machineList.assignAll([]);
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "No Machines Found",
            text: "There is no machine fetched for this BRM"
          )
        );
        selectedMachineType.value = 'assy'; // Default
      }
      
    } catch (e) {
      print('Error getting machines by task: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Gagal mengambil data mesin: $e"
        )
      );
      
      // Fallback: If API call fails, show message that no machines were fetched
      machineList.assignAll([]);
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: "No Machines Found",
          text: "There is no machine fetched for this BRM"
        )
      );
      selectedMachineType.value = 'assy'; // Default
    } finally {
      isLoading.value = false;
    }
  }

  Future<JSAny?> getForm(String taskId) async {
    try {
      // Try needle-assy machines
      final needle = await Api.get("form-d/form/${taskId}");
      if (needle != null) return needle;
    } catch (e) {
      print('Error getting needle-assy form data: $e');
    }
    
    return null;
  }

  Future<void> getMachinesByBrm(String brmNo) async {

    try {
      final blisterByBrmResponse = await Api.get('display-machine-blister/brm/$brmNo');
      if (blisterByBrmResponse != null) {
        List<dynamic> blisterDisplays = blisterByBrmResponse;
        for (var item in blisterDisplays) {
          item['machine_type'] = 'blister';
        }

        // Add to machine display list if not already present
        for (var item in blisterDisplays) {
          bool exists = false;
          for (var existing in machineDisplayList) {
            if (existing['machine'] != null &&
                item['machine'] != null &&
                existing['machine']['id_machine'] == item['machine']['id_machine'] &&
                existing['brm_no'] == item['brm_no']) {
              exists = true;
              break;
            }
          }

          if (!exists) {
            machineDisplayList.add(item);
          }
        }
      }

      final sgpByBrmResponse = await Api.get('display-machine-sgp/brm/$brmNo');
      if (sgpByBrmResponse != null) {
        List<dynamic> sgpDisplays = sgpByBrmResponse;
        for (var item in sgpDisplays) {
          item['machine_type'] = 'sgp';
        }

        // Add to machine display list if not already present
        for (var item in sgpDisplays) {
          bool exists = false;
          for (var existing in machineDisplayList) {
            if (existing['machine'] != null &&
                item['machine'] != null &&
                existing['machine']['id_machine'] == item['machine']['id_machine'] &&
                existing['brm_no'] == item['brm_no']) {
              exists = true;
              break;
            }
          }

          if (!exists) {
            machineDisplayList.add(item);
          }
        }
      }
    } catch (e) {
      print('Error getting machines by BRM: $e');
    }
  }


  Future<bool> checkAssyValue() async {
    isLoading.value = true;
    try {
      final response = await Api.get('/machine-assy/${taskId.value}');
      
      if (response != null) {
        // Process the response data
        print('Machine Assy data retrieved successfully');
        // Update form fields if needed
        if (response['data'] != null) {
          var data = response['data'];
          actualRunning.value = data['actual_running']?.toString() ?? '';
          runAwal.value = data['run_awal']?.toString() ?? '';
          defect.value = data['defect']?.toString() ?? '';
          goodsOk.value = data['goods_ok']?.toString() ?? '';
          goodsReject.value = data['goods_reject']?.toString() ?? '';
        }
        return true;
      } else {
        // Handle case when no data is found
        print('No Machine Assy data found for this task');
        return false;
      }
    } catch (e) {
      print('Error retrieving Machine Assy data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Failed to retrieve Machine Assy data: $e"
        )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> checkBlisterValue() async {
    isLoading.value = true;
    
    try {
      final response = await Api.get('/machine-blister/${taskId.value}');

      if (response != null) {
        // Process the response data
        print('Machine Assy data retrieved successfully');
        // Update form fields if needed
        if (response['data'] != null) {
          var data = response['data'];

          materialType.value = data['material_type']?.toString() ?? '';
          formingTime.value = data['forming_time']?.toString() ?? '';
          formingTemperature.value =
              data['forming_temperature']?.toString() ?? '';
          formingPressure.value = data['forming_pressure']?.toString() ?? '';
          sealingTemperature.value =
              data['sealing_temperature']?.toString() ?? '';
          sealingPressure.value = data['sealing_pressure']?.toString() ?? '';
          sealingTime.value = data['sealing_time']?.toString() ?? '';
          actualRunning.value = data['actual_running']?.toString() ?? '';
          defect.value = data['defect']?.toString() ?? '';
          goodsOk.value = data['goods_ok']?.toString() ?? '';
          goodsReject.value = data['goods_reject']?.toString() ?? '';
          // Load new fields
          cycleTime.value = data['cycle_time']?.toString() ?? '';
          mfgDate.value = data['mfg_date']?.toString() ?? '';
          expDate.value = data['exp_date']?.toString() ?? '';
          needleSize.value = data['needle_size']?.toString() ?? '';
          nie.value = data['nie']?.toString() ?? '';
        }
        return true;
      } else {
        // Handle case when no data is found
        print('No Machine Blister data found for this task');
        return false;
      }
    } catch (e) {
      print('Error retrieving Machine Blister data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Failed to retrieve Machine Blister data: $e"
        )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkFcsShiValue() async {
    isLoading.value = true;
    try {
      final response = await Api.get('/machine-fcs-shi/${taskId.value}');

      if (response != null) {
        // Process the response data
        return response;
      } else {
        // Handle case when no data is found
        print('No Assy Syringe data found for this task');
        return null;
      }
    } catch (e) {
      print('Error retrieving Assy Syringe data: $e');
      ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Failed to retrieve Assy Syringe data: $e"
          )
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkSgpValue() async {
    isLoading.value = true;
    try {
      final response = await Api.get('/machine-sgp/${taskId.value}');
      
      if (response != null) {
        // Process the response data
        print('Machine SGP data retrieved successfully');
        // Update form fields if needed
        if (response['data'] != null) {
          var data = response['data'];
          materialType.value = data['material_type']?.toString() ?? '';
          moldTemperature.value = data['mold_temperature']?.toString() ?? '';
          injectionPressure.value = data['injection_pressure']?.toString() ?? '';
          injectionSpeed.value = data['injection_speed']?.toString() ?? '';
          holdingPressure.value = data['holding_pressure']?.toString() ?? '';
          holdingTime.value = data['holding_time']?.toString() ?? '';
          coolingTime.value = data['cooling_time']?.toString() ?? '';
          actualRunning.value = data['actual_running']?.toString() ?? '';
          runAwal.value = data['cycle_time']?.toString() ?? '';
          defect.value = data['defect']?.toString() ?? '';
          goodsOk.value = data['goods_ok']?.toString() ?? '';
          goodsReject.value = data['goods_reject']?.toString() ?? '';
          temp1.value = data['temp1']?.toString() ?? '';
          temp2.value = data['temp2']?.toString() ?? '';
          temp3.value = data['temp3']?.toString() ?? '';
          temp4.value = data['temp4']?.toString() ?? '';
          loadCap.value = data['load_cap'] ?? false;
          loadHub.value = data['load_hub'] ?? false;
          loadNeedle.value = data['load_needle'] ?? false;
          hasilEpoxy.value = data['hasil_epoxy'] ?? false;
          pressureActual.value = data['pressure_actual']?.toString() ?? '';
          pressureStatus.value = data['pressure_status'] ?? false;
          lowEpoxy1.value = data['low_epoxy1'] ?? false;
          lowEpoxy2.value = data['low_epoxy2'] ?? false;
          lowEpoxy3.value = data['low_epoxy3'] ?? false;
          hubCanula1.value = data['hub_canula1'] ?? false;
          hubCanula2.value = data['hub_canula2'] ?? false;
          hubCanula3.value = data['hub_canula3'] ?? false;
          excEpoxy1.value = data['exc_epoxy1'] ?? false;
          excEpoxy2.value = data['exc_epoxy2'] ?? false;
          excEpoxy3.value = data['exc_epoxy3'] ?? false;
          needleTumpul1.value = data['needle_tumpul1'] ?? false;
          needleTumpul2.value = data['needle_tumpul2'] ?? false;
          needleTumpul3.value = data['needle_tumpul3'] ?? false;
          needleBalik1.value = data['needle_balik1'] ?? false;
          needleBalik2.value = data['needle_balik2'] ?? false;
          needleBalik3.value = data['needle_balik3'] ?? false;
          needleTersumbat1.value = data['needle_tersumbat1'] ?? false;
          needleTersumbat2.value = data['needle_tersumbat2'] ?? false;
          needleTersumbat3.value = data['needle_tersumbat3'] ?? false;
        }
        return true;
      } else {
        // Handle case when no data is found
        print('No Machine SGP data found for this task');
        return false;
      }
    } catch (e) {
      print('Error retrieving Machine SGP data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Failed to retrieve Machine SGP data: $e"
        )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAssyValue({
    required String codeTask,
    required int taskId,
    String? actualRunning,
    String? runAwal,
    String? defect,
    String? goodsOk,
    String? goodsReject,
    String? qcBarrel,
    String? qcGasket,
    String? qcPlunger,
    String? printMatchSpeed,
    String? assyMatchSpeed,
    int? formDId,
    bool? loadBarrel,
    bool? loadPlunger,
    bool? loadGasket,
    dynamic machinePicture,
  }) async {
    isLoading.value = true;

    try {
      // Prepare data for API call
      final data = {
        'code_task': codeTask,

        'form_d_id': formDId,
        'task_id': taskId,
      };
      for (final entry in parameterControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          if(entry.value.text == 'true' || entry.value.text == 'false') {
            data[entry.key] = entry.value.text == 'true';
          } else {
            // Convert to string if not boolean
            data[entry.key] = entry.value.text;
          }
        }
      }

      // Add machine picture if provided
      if (machinePicture != null) {
        data['machine_picture'] = machinePicture;
      }

      // Send data to API
      final response = await Api.post('form-d/machine-assy', data);

      if (response != null) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Berhasil",
                text: "Machine Assy data berhasil disimpan"
            )
        );
        return true;
      } else {
        throw Exception('Failed to store Machine Assy data');
      }
    } catch (e) {
      print('Error submitting Machine Assy data: $e');
      ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Terjadi kesalahan saat mengirim data Machine Assy: $e"
          )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> storeBlisterValue({
    required String codeTask,
    required int taskId,
    int? formDId,
    String? materialType,
    String? formingTime,
    String? formingTemperature,
    String? formingPressure,
    String? sealingTemperature,
    String? sealingPressure,
    String? sealingTime,
    String? actualRunning,
    String? defect,
    String? goodsOk,
    String? goodsReject,
    String? cycleTime,
    String? mfgDate,
    String? expDate,
    String? needleSize,
    String? nie,
    dynamic machinePicture,
  }) async {
    isLoading.value = true;
    
    try {
      // Prepare data for API call
      final data = {
        'code_task': codeTask,
        'material_type': materialType,
        'forming_time': formingTime,
        'forming_temperature': formingTemperature,
        'forming_pressure': formingPressure,
        'sealing_temperature': sealingTemperature,
        'sealing_pressure': sealingPressure,
        'sealing_time': sealingTime,
        'task_id': taskId,
        'form_d_id': formDId,
        'actual_running': actualRunning,
        'defect': defect,
        'goods_ok': goodsOk,
        'goods_reject': goodsReject,
        'cycle_time': cycleTime,
        'mfg_date': mfgDate,
        'exp_date': expDate,
        'needle_size': needleSize,
        'nie': nie,
      };
      
      // Add machine picture if provided
      if (machinePicture != null) {
        data['machine_picture'] = machinePicture;
      }
      
      // Send data to API
      final response = await Api.post('form-d/machine-blister', data);
      
      if (response != null) {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Berhasil",
            text: "Machine Blister data berhasil disimpan"
          )
        );
        return true;
      } else {
        throw Exception('Failed to store Machine Blister data');
      }
    } catch (e) {
      print('Error submitting Machine Blister data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Terjadi kesalahan saat mengirim data Machine Blister: $e"
        )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> storeSgpValue({
    required String codeTask,
    required int formDId,
    required int taskId,
    String? materialType,
    // New SGP parameters
    String? moldTemperature,
    String? injectionPressure,
    String? injectionSpeed,
    String? holdingPressure,
    String? holdingTime,
    String? coolingTime,
    // Production data
    String? actualRunning,
    String? cycleTime,
    String? defect,
    String? goodsOk,
    String? goodsReject,
    // Original parameters
    String? temp1,
    String? temp2,
    String? temp3,
    String? temp4,
    bool? loadCap,
    bool? loadHub,
    bool? loadNeedle,
    bool? hasilEpoxy,
    String? pressureActual,
    bool? pressureStatus,
    bool? lowEpoxy1,
    bool? lowEpoxy2,
    bool? lowEpoxy3,
    bool? hubCanula1,
    bool? hubCanula2,
    bool? hubCanula3,
    bool? excEpoxy1,
    bool? excEpoxy2,
    bool? excEpoxy3,
    bool? needleTumpul1,
    bool? needleTumpul2,
    bool? needleTumpul3,
    bool? needleBalik1,
    bool? needleBalik2,
    bool? needleBalik3,
    bool? needleTersumbat1,
    bool? needleTersumbat2,
    bool? needleTersumbat3,
    dynamic machinePicture,
  }) async {
    isLoading.value = true;
    
    try {
      // Prepare data for API call
      final data = {
        'code_task': codeTask,
        'material_type': materialType,
        // New SGP parameters
        'mold_temperature': moldTemperature,
        'injection_pressure': injectionPressure,
        'injection_speed': injectionSpeed,
        'holding_pressure': holdingPressure,
        'holding_time': holdingTime,
        'cooling_time': coolingTime,
        // Production data
        'actual_running': actualRunning,
        'cycle_time': cycleTime,
        'defect': defect,
        'goods_ok': goodsOk,
        'goods_reject': goodsReject,
        // Original parameters
        'temp1': temp1,
        'temp2': temp2,
        'temp3': temp3,
        'temp4': temp4,
        'load_cap': loadCap,
        'load_hub': loadHub,
        'load_needle': loadNeedle,
        'hasil_epoxy': hasilEpoxy,
        'pressure_actual': pressureActual,
        'pressure_status': pressureStatus,
        'low_epoxy1': lowEpoxy1,
        'low_epoxy2': lowEpoxy2,
        'low_epoxy3': lowEpoxy3,
        'hub_canula1': hubCanula1,
        'hub_canula2': hubCanula2,
        'hub_canula3': hubCanula3,
        'exc_epoxy1': excEpoxy1,
        'exc_epoxy2': excEpoxy2,
        'exc_epoxy3': excEpoxy3,
        'needle_tumpul1': needleTumpul1,
        'needle_tumpul2': needleTumpul2,
        'needle_tumpul3': needleTumpul3,
        'needle_balik1': needleBalik1,
        'needle_balik2': needleBalik2,
        'needle_balik3': needleBalik3,
        'needle_tersumbat1': needleTersumbat1,
        'needle_tersumbat2': needleTersumbat2,
        'needle_tersumbat3': needleTersumbat3,
        'form_d_id': formDId,
        'task_id': taskId,
      };
      
      // Add machine picture if provided
      if (machinePicture != null) {
        data['machine_picture'] = machinePicture;
      }
      
      // Send data to API
      final response = await Api.post('/machine-sgp', data);
      
      if (response != null) {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Berhasil",
            text: "Machine SGP data berhasil disimpan"
          )
        );
        return true;
      } else {
        throw Exception('Failed to store Machine SGP data');
      }
    } catch (e) {
      print('Error submitting Machine SGP data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Terjadi kesalahan saat mengirim data Machine SGP: $e"
        )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> storeFcsShiValue({
    required String codeTask,
    required int formDId,
    required int taskId,
    String? tempNozzleZ1,
    String? tempNozzleZ2,
    String? tempNozzleZ3,
    String? tempNozzleZ4,
    String? tempNozzleZ5,
    String? tempMold,
    String? injectPressure,
    String? injectTime,
    String? holdingPressure,
    String? holdingTime,
    String? ejectCounter,
    String? cycleTime,
    String? masterbatch,
    String? beratProduk,
    String? beratRunner,
    String? cavity,
    String? sampling,
    String? defect,
    dynamic machinePicture,
  }) async {
    isLoading.value = true;

    try {
      // Prepare data for API call
      final data = {
        'code_task': codeTask,
        'temp_nozzle_z1': tempNozzleZ1,
        'temp_nozzle_z2': tempNozzleZ2,
        'temp_nozzle_z3': tempNozzleZ3,
        'temp_nozzle_z4': tempNozzleZ4,
        'temp_nozzle_z5': tempNozzleZ5,
        'temp_mold': tempMold,
        'inject_pressure': injectPressure,
        'inject_time': injectTime,
        'holding_pressure': holdingPressure,
        'holding_time': holdingTime,
        'eject_counter': ejectCounter,
        'cycle_time': cycleTime,
        'masterbatch': masterbatch,
        'berat_produk': beratProduk,
        'berat_runner': beratRunner,
        'cavity': cavity,
        'sampling': sampling,
        'defect': defect,
        'form_d_id': formDId,
        'task_id': taskId,
      };

      // Add machine picture if provided
      if (machinePicture != null) {
        data['machine_picture'] = machinePicture;
      }

      // Send data to API
      final response = await Api.post('/machine-fcs-shi', data);

      if (response != null) {
        ArtSweetAlert.show(
            context: Get.context!,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Berhasil",
                text: "Assy Syringe data berhasil disimpan"
            )
        );
        return true;
      } else {
        throw Exception('Failed to store Assy Syringe data');
      }
    } catch (e) {
      print('Error submitting Assy Syringe data: $e');
      ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Terjadi kesalahan saat mengirim data Assy Syringe: $e"
          )
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }



  Future<bool> submitForm({
    required int machineId,
    required String brmNo,
    required String materialType,
    required String codeTask,
    required String shift,
    required int taskId,
    required DateTime tanggal,
    String? printMatchSpeed,
    String? assyMatchSpeed,
    bool? loadBarrel,
    bool? loadPlunger,
    bool? loadGasket,
    String? actualRunning,
    String? runAwal,
    String? defect,
    String? goodsOk,
    String? goodsReject,
    dynamic machinePicture,
    dynamic lineClearance,
    // Blister specific parameters
    String? formingTime,
    String? formingTemperature,
    String? formingPressure,
    String? sealingTemperature,
    String? sealingPressure,
    String? sealingTime,
    String? cycleTime,
    String? mfgDate,
    String? expDate,
    String? needleSize,
    String? nie,
    // SGP specific parameters
    String? moldTemperature,
    String? injectionPressure,
    String? injectionSpeed,
    String? holdingPressure,
    String? holdingTime,
    String? coolingTime,
    String? temp1,
    String? temp2,
    String? temp3,
    String? temp4,
    bool? loadCap,
    bool? loadHub,
    bool? loadNeedle,
    bool? hasilEpoxy,
    String? pressureActual,
    bool? pressureStatus,
    bool? lowEpoxy1,
    bool? lowEpoxy2,
    bool? lowEpoxy3,
    bool? hubCanula1,
    bool? hubCanula2,
    bool? hubCanula3,
    bool? excEpoxy1,
    bool? excEpoxy2,
    bool? excEpoxy3,
    bool? needleTumpul1,
    bool? needleTumpul2,
    bool? needleTumpul3,
    bool? needleBalik1,
    bool? needleBalik2,
    bool? needleBalik3,
    bool? needleTersumbat1,
    bool? needleTersumbat2,
    bool? needleTersumbat3,
    String? type,
  }) async {
    isLoading.value = true;

    try {
      final formDResponse = await Api.post('form-d', {
        'tanggal': tanggal.toIso8601String(),
        'machine_id': machineId,
        'material_type': materialType,
        'code_task': codeTask,
        'brm_no': brmNo,
        'shift': GetStorage().read('group'),
        'task_id': taskId,
        'line_clear': lineClearance is bool ? lineClearance : (lineClearance == 'Sudah'),
      });

      if (formDResponse == null || formDResponse['data'] == null) {
        throw Exception('Failed to create Form D record');
      }

      final formDId = formDResponse['data']['id_form_d'];

      bool machineDataResult = false;


      if (type == 'assysyringe') {
        // Create Assy values
        machineDataResult = await createAssyValue(
          codeTask: codeTask,
          taskId: taskId,
          actualRunning: actualRunning,
          runAwal: runAwal,
          defect: defect,
          goodsOk: parameterControllers['goods_ok']?.text,
          goodsReject: parameterControllers['goods_reject']?.text,
          machinePicture: machinePicture,
          printMatchSpeed: parameterControllers['print_match_speed']?.text,
          assyMatchSpeed: parameterControllers['assy_match_speed']?.text,
          formDId: formDId,
          loadBarrel: bool.parse(parameterControllers['load_barrel']?.text  ?? 'false'),
          loadPlunger: bool.parse(parameterControllers['load_plunger']?.text ?? 'false'),
          loadGasket: bool.parse(parameterControllers['load_gasket']?.text ?? 'false'),
        );
      } else if (type == 'blister') {
        machineDataResult = await storeBlisterValue(
          codeTask: codeTask,
          taskId: taskId,
          formDId: formDId,
          materialType: materialType,
          formingTime: parameterControllers['forming_time']?.text,
          formingTemperature: parameterControllers['formingTemperature']?.text,
          formingPressure: parameterControllers['formingPressure']?.text,
          sealingTemperature: parameterControllers['sealingTemperature']?.text,
          sealingPressure: parameterControllers['sealingPressure']?.text,
          sealingTime: parameterControllers['sealingTime']?.text,
          cycleTime: cycleTime,
          mfgDate: tanggal.toIso8601String(),
          expDate: tanggal.toIso8601String(),
          needleSize: needleSize,
          nie: nie,
          machinePicture: machinePicture,
        );
      } else if (type == 'sgp') {
        // Create SGP values
        machineDataResult = await storeSgpValue(
          codeTask: codeTask,
          formDId: formDId,
          taskId: taskId,
          materialType: materialType,
          moldTemperature: moldTemperature,
          injectionPressure: injectionPressure,
          injectionSpeed: injectionSpeed,
          holdingPressure: holdingPressure,
          holdingTime: holdingTime,
          coolingTime: coolingTime,
          actualRunning: actualRunning,
          cycleTime: runAwal,
          defect: defect,
          goodsOk: goodsOk,
          goodsReject: goodsReject,
          temp1: temp1,
          temp2: temp2,
          temp3: temp3,
          temp4: temp4,
          loadCap: loadCap,
          loadHub: loadHub,
          loadNeedle: loadNeedle,
          hasilEpoxy: hasilEpoxy,
          pressureActual: pressureActual,
          pressureStatus: pressureStatus,
          lowEpoxy1: lowEpoxy1,
          lowEpoxy2: lowEpoxy2,
          lowEpoxy3: lowEpoxy3,
          hubCanula1: hubCanula1,
          hubCanula2: hubCanula2,
          hubCanula3: hubCanula3,
          excEpoxy1: excEpoxy1,
          excEpoxy2: excEpoxy2,
          excEpoxy3: excEpoxy3,
          needleTumpul1: needleTumpul1,
          needleTumpul2: needleTumpul2,
          needleTumpul3: needleTumpul3,
          needleBalik1: needleBalik1,
          needleBalik2: needleBalik2,
          needleBalik3: needleBalik3,
          needleTersumbat1: needleTersumbat1,
          needleTersumbat2: needleTersumbat2,
          needleTersumbat3: needleTersumbat3,
          machinePicture: machinePicture,
        );
      } else if (type == 'fcs_shi' || type == 'fcs' || type == 'shi_1' || type == 'shi_2') {
        // These machine types might use the FCS-SHI form
      } else {
        // Show error for unsupported machine type
        Get.snackbar(
          'Error',
          'Unsupported machine type: $type',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        machineDataResult = false;
      }
      return true;
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