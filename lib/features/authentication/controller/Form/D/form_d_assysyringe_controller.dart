import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oji_1/common/api.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:oji_1/utils/js_interop_stub.dart';

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
      final needle = await Api.get("form-d/form/$taskId");
      if (needle != null) return JSAny(needle);
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
        return;
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
      return;
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

  Future<bool> storeFcsValue({
    dynamic machinePicture,
    required String codeTask,
    required int taskId,
    int? formDId,
    String? materialType,
  }) async {
    isLoading.value = true;
    
    try {
      // Prepare data for API call
      final data = {
        'code_task': codeTask,
        'material_type': materialType,
        'form_d_id': formDId,
        'task_id': taskId,
        // Open Position parameters
        'open_position_slow': parameterControllers['open_position_slow']?.text,
        'open_position_fast': parameterControllers['open_position_fast']?.text,
        'open_position_mid': parameterControllers['open_position_mid']?.text,
        'open_position_dec': parameterControllers['open_position_dec']?.text,

        // Open Speed parameters
        'open_speed_slow': parameterControllers['open_speed_slow']?.text,
        'open_speed_fast': parameterControllers['open_speed_fast']?.text,
        'open_speed_mid': parameterControllers['open_speed_mid']?.text,
        'open_speed_dec': parameterControllers['open_speed_dec']?.text,

        // Sealing Temperature
        'sealing_temperature': parameterControllers['sealing_temperature']?.text,

        // Open Pressure parameters
        'open_pressure_slow': parameterControllers['open_pressure_slow']?.text,
        'open_pressure_fast': parameterControllers['open_pressure_fast']?.text,
        'open_pressure_mid': parameterControllers['open_pressure_mid']?.text,
        'open_pressure_dec': parameterControllers['open_pressure_dec']?.text,

        // Close Position parameters
        'close_position_slow': parameterControllers['close_position_slow']?.text,
        'close_position_fast': parameterControllers['close_position_fast']?.text,
        'close_position_mid': parameterControllers['close_position_mid']?.text,
        'close_position_dec': parameterControllers['close_position_dec']?.text,

        // Close Speed parameters
        'close_speed_slow': parameterControllers['close_speed_slow']?.text,
        'close_speed_fast': parameterControllers['close_speed_fast']?.text,
        'close_speed_mid': parameterControllers['close_speed_mid']?.text,
        'close_speed_dec': parameterControllers['close_speed_dec']?.text,

        // Close Pressure parameters
        'close_pressure_slow': parameterControllers['close_pressure_slow']?.text,
        'close_pressure_fast': parameterControllers['close_pressure_fast']?.text,
        'close_pressure_mid': parameterControllers['close_pressure_mid']?.text,
        'close_pressure_dec': parameterControllers['close_pressure_dec']?.text,

        // Ejector Position parameters
        'ejector_position_ret2': parameterControllers['ejector_position_ret2']?.text,
        'ejector_position_ret1': parameterControllers['ejector_position_ret1']?.text,
        'ejector_position_adv2': parameterControllers['ejector_position_adv2']?.text,
        'ejector_position_adv1': parameterControllers['ejector_position_adv1']?.text,

        // Ejector Speed parameters
        'ejector_speed_ret2': parameterControllers['ejector_speed_ret2']?.text,
        'ejector_speed_ret1': parameterControllers['ejector_speed_ret1']?.text,
        'ejector_speed_adv2': parameterControllers['ejector_speed_adv2']?.text,
        'ejector_speed_adv1': parameterControllers['ejector_speed_adv1']?.text,

        // Ejector Pressure parameters
        'ejector_pressure_ret2': parameterControllers['ejector_pressure_ret2']?.text,
        'ejector_pressure_ret1': parameterControllers['ejector_pressure_ret1']?.text,
        'ejector_pressure_adv2': parameterControllers['ejector_pressure_adv2']?.text,
        'ejector_pressure_adv1': parameterControllers['ejector_pressure_adv1']?.text,

        // Temperature SV parameters
        'temperature_sv_sect1': parameterControllers['temperature_sv_sect1']?.text,
        'temperature_sv_sect2': parameterControllers['temperature_sv_sect2']?.text,
        'temperature_sv_sect3': parameterControllers['temperature_sv_sect3']?.text,
        'temperature_sv_sect4': parameterControllers['temperature_sv_sect4']?.text,
        'temperature_sv_sect5': parameterControllers['temperature_sv_sect5']?.text,
        'temperature_sv_sect6': parameterControllers['temperature_sv_sect6']?.text,

        // Temperature PV parameters
        'temperature_pv_sect1': parameterControllers['temperature_pv_sect1']?.text,
        'temperature_pv_sect2': parameterControllers['temperature_pv_sect2']?.text,
        'temperature_pv_sect3': parameterControllers['temperature_pv_sect3']?.text,
        'temperature_pv_sect4': parameterControllers['temperature_pv_sect4']?.text,
        'temperature_pv_sect5': parameterControllers['temperature_pv_sect5']?.text,
        'temperature_pv_sect6': parameterControllers['temperature_pv_sect6']?.text,

        // Temperature PRE parameters
        'temperature_pre_sect1': parameterControllers['temperature_pre_sect1']?.text,
        'temperature_pre_sect2': parameterControllers['temperature_pre_sect2']?.text,
        'temperature_pre_sect3': parameterControllers['temperature_pre_sect3']?.text,
        'temperature_pre_sect4': parameterControllers['temperature_pre_sect4']?.text,
        'temperature_pre_sect5': parameterControllers['temperature_pre_sect5']?.text,
        'temperature_pre_sect6': parameterControllers['temperature_pre_sect6']?.text,

        // Temperature MAX parameters
        'temperature_max_sect1': parameterControllers['temperature_max_sect1']?.text,
        'temperature_max_sect2': parameterControllers['temperature_max_sect2']?.text,
        'temperature_max_sect3': parameterControllers['temperature_max_sect3']?.text,
        'temperature_max_sect4': parameterControllers['temperature_max_sect4']?.text,
        'temperature_max_sect5': parameterControllers['temperature_max_sect5']?.text,
        'temperature_max_sect6': parameterControllers['temperature_max_sect6']?.text,

        // Temperature LOW parameters
        'temperature_low_sect1': parameterControllers['temperature_low_sect1']?.text,
        'temperature_low_sect2': parameterControllers['temperature_low_sect2']?.text,
        'temperature_low_sect3': parameterControllers['temperature_low_sect3']?.text,
        'temperature_low_sect4': parameterControllers['temperature_low_sect4']?.text,
        'temperature_low_sect5': parameterControllers['temperature_low_sect5']?.text,
        'temperature_low_sect6': parameterControllers['temperature_low_sect6']?.text,

        // Filling Position parameters
        'filling_position_inj5': parameterControllers['filling_position_inj5']?.text,
        'filling_position_inj4': parameterControllers['filling_position_inj4']?.text,
        'filling_position_inj3': parameterControllers['filling_position_inj3']?.text,
        'filling_position_inj2': parameterControllers['filling_position_inj2']?.text,
        'filling_position_inj1': parameterControllers['filling_position_inj1']?.text,

        // Filling Velocity parameters
        'filling_velocity_inj5': parameterControllers['filling_velocity_inj5']?.text,
        'filling_velocity_inj4': parameterControllers['filling_velocity_inj4']?.text,
        'filling_velocity_inj3': parameterControllers['filling_velocity_inj3']?.text,
        'filling_velocity_inj2': parameterControllers['filling_velocity_inj2']?.text,
        'filling_velocity_inj1': parameterControllers['filling_velocity_inj1']?.text,

        // Filling Pressure parameters
        'filling_pressure_inj5': parameterControllers['filling_pressure_inj5']?.text,
        'filling_pressure_inj4': parameterControllers['filling_pressure_inj4']?.text,
        'filling_pressure_inj3': parameterControllers['filling_pressure_inj3']?.text,
        'filling_pressure_inj2': parameterControllers['filling_pressure_inj2']?.text,
        'filling_pressure_inj1': parameterControllers['filling_pressure_inj1']?.text,

        // Filling Time parameters
        'filling_time_inj5': parameterControllers['filling_time_inj5']?.text,
        'filling_time_inj4': parameterControllers['filling_time_inj4']?.text,
        'filling_time_inj3': parameterControllers['filling_time_inj3']?.text,
        'filling_time_inj2': parameterControllers['filling_time_inj2']?.text,
        'filling_time_inj1': parameterControllers['filling_time_inj1']?.text,

        // Holding Speed parameters
        'holding_speed_hdp4': parameterControllers['holding_speed_hdp4']?.text,
        'holding_speed_hdp3': parameterControllers['holding_speed_hdp3']?.text,
        'holding_speed_hdp2': parameterControllers['holding_speed_hdp2']?.text,
        'holding_speed_hdp1': parameterControllers['holding_speed_hdp1']?.text,

        // Holding Pressure parameters
        'holding_pressure_hdp4': parameterControllers['holding_pressure_hdp4']?.text,
        'holding_pressure_hdp3': parameterControllers['holding_pressure_hdp3']?.text,
        'holding_pressure_hdp2': parameterControllers['holding_pressure_hdp2']?.text,
        'holding_pressure_hdp1': parameterControllers['holding_pressure_hdp1']?.text,

        // Charging Back parameters
        'charging_back_pre': parameterControllers['charging_back_pre']?.text,
        'charging_back_charge1': parameterControllers['charging_back_charge1']?.text,
        'charging_back_charge2': parameterControllers['charging_back_charge2']?.text,
        'charging_back_charge3': parameterControllers['charging_back_charge3']?.text,
        'charging_back_post': parameterControllers['charging_back_post']?.text,

        // Charging Speed parameters
        'charging_speed_pre': parameterControllers['charging_speed_pre']?.text,
        'charging_speed_charge1': parameterControllers['charging_speed_charge1']?.text,
        'charging_speed_charge2': parameterControllers['charging_speed_charge2']?.text,
        'charging_speed_charge3': parameterControllers['charging_speed_charge3']?.text,
        'charging_speed_post': parameterControllers['charging_speed_post']?.text,

        // Charging Pressure parameters
        'charging_pressure_pre': parameterControllers['charging_pressure_pre']?.text,
        'charging_pressure_charge1': parameterControllers['charging_pressure_charge1']?.text,
        'charging_pressure_charge2': parameterControllers['charging_pressure_charge2']?.text,
        'charging_pressure_charge3': parameterControllers['charging_pressure_charge3']?.text,
        'charging_pressure_post': parameterControllers['charging_pressure_post']?.text,

        // Charging Position parameters
        'charging_position_pre': parameterControllers['charging_position_pre']?.text,
        'charging_position_charge1': parameterControllers['charging_position_charge1']?.text,
        'charging_position_charge2': parameterControllers['charging_position_charge2']?.text,
        'charging_position_charge3': parameterControllers['charging_position_charge3']?.text,
        'charging_position_post': parameterControllers['charging_position_post']?.text,

        // Purge Velocity parameters
        'purge_velocity_slow': parameterControllers['purge_velocity_slow']?.text,
        'purge_velocity_fast': parameterControllers['purge_velocity_fast']?.text,
        'purge_velocity_back': parameterControllers['purge_velocity_back']?.text,

        // Purge Pressure parameters
        'purge_pressure_slow': parameterControllers['purge_pressure_slow']?.text,
        'purge_pressure_fast': parameterControllers['purge_pressure_fast']?.text,
        'purge_pressure_back': parameterControllers['purge_pressure_back']?.text,

        // Purge Position parameters
        'purge_position_slow': parameterControllers['purge_position_slow']?.text,
        'purge_position_fast': parameterControllers['purge_position_fast']?.text,
        'purge_position_back': parameterControllers['purge_position_back']?.text,
      };
      
      // Add machine picture if provided
      if (machinePicture != null) {
        data['machine_picture'] = machinePicture;
      }
      
      // Send data to API
      final response = await Api.post('/machine-fcs', data);
      
      if (response != null) {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Berhasil",
            text: "Machine FCS data berhasil disimpan"
          )
        );
        return true;
      } else {
        ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Error",
            text: "Gagal menyimpan data Machine FCS"
          )
        );
        return false;
      }
    } catch (e) {
      print('Error submitting Machine FCS data: $e');
      ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Terjadi kesalahan saat mengirim data Machine FCS: $e"
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
      } else if (type == 'fcs_shi') {

      } else if (type == 'fcs') {
        machineDataResult = await storeFcsValue(
          machinePicture: machinePicture,
          codeTask: codeTask,
          taskId: taskId,
          formDId: formDId,
          materialType: materialType,
        );
      } else if (type == 'sgp') {

      } else if (type == 'shi_1') {

      } else if (type == 'shi_2') {

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