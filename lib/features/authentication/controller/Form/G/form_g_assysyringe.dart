import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oji_1/common/api.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';

class FormGAssySyringeController extends GetxController {
  var isLoading = false.obs;
  var remarks = ''.obs;
  var inisial1 = ''.obs;
  var inisial2 = ''.obs;
  var inisial3 = ''.obs;
  var taskCode = ''.obs;
  var taskId = 0.obs;
  
  Rx<Uint8List?> signature1 = Rx<Uint8List?>(null);
  Rx<Uint8List?> signature2 = Rx<Uint8List?>(null);
  Rx<Uint8List?> signature3 = Rx<Uint8List?>(null);

  void setTaskInfo(Task task) {
    taskCode.value = task.code ?? '';
    taskId.value = task.id ?? 0;
  }

  void setRemarks(String value) {
    remarks.value = value;
  }

  void setInisial1(String value) {
    inisial1.value = value;
  }

  void setInisial2(String value) {
    inisial2.value = value;
  }

  void setInisial3(String value) {
    inisial3.value = value;
  }

  void setSignature1(Uint8List? value) {
    signature1.value = value;
  }

  void setSignature2(Uint8List? value) {
    signature2.value = value;
  }

  void setSignature3(Uint8List? value) {
    signature3.value = value;
  }

  Future<bool> submitForm(BuildContext context) async {
    try {
      isLoading.value = true;

      var url = Uri.parse('${ApiConfig.baseUrl}/form-g-assy-syringe');

      Map<String, dynamic> requestBody = {
        'remarks': remarks.value,
        'inisial_1': inisial1.value,
        'inisial_2': inisial2.value,
        'inisial_3': inisial3.value,
        'task_code': taskCode.value,
        'task_id': taskId.value.toString(),
      };

      // Convert signatures to base64 if they exist
      if (signature1.value != null) {
        requestBody['signed_1'] = base64Encode(signature1.value!);
      }

      if (signature2.value != null) {
        requestBody['signed_2'] = base64Encode(signature2.value!);
      }

      if (signature3.value != null) {
        requestBody['signed_3'] = base64Encode(signature3.value!);
      }

      // Send the request
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('auth_token') ?? ''}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success
        await ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Success",
            text: "Form G Assy Syringe submitted successfully",
          ),
        );
        return true;
      } else {
        // Error
        String errorMessage = "Failed to submit form";
        try {
          var jsonResponse = json.decode(response.body);
          errorMessage = jsonResponse['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use the raw response or a default message
          errorMessage = response.body.isNotEmpty ?
              "Server error: ${response.statusCode}" :
              "Failed to submit form with status: ${response.statusCode}";
        }

        await ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Error",
            text: errorMessage,
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error in submitForm: ${e.toString()}');
      await ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "An error occurred: ${e.toString()}",
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Method to get form data by task ID
  Future<Map<String, dynamic>?> getFormByTaskId(int taskId) async {
    try {
      isLoading.value = true;

      final box = GetStorage();
      final token = box.read('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API response
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/form-g-assy-syringe/$taskId?is_task_id=true'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
            var formData = jsonResponse['data'][0];

            // Convert base64 signatures back to Uint8List if they exist
            if (formData['has_signed_1'] == true && formData['signed_1'] != null) {
              signature1.value = base64Decode(formData['signed_1']);
            }

            if (formData['has_signed_2'] == true && formData['signed_2'] != null) {
              signature2.value = base64Decode(formData['signed_2']);
            }

            if (formData['has_signed_3'] == true && formData['signed_3'] != null) {
              signature3.value = base64Decode(formData['signed_3']);
            }

            // Set other form values
            remarks.value = formData['remarks'] ?? '';
            inisial1.value = formData['inisial_1'] ?? '';
            inisial2.value = formData['inisial_2'] ?? '';
            inisial3.value = formData['inisial_3'] ?? '';

            return formData;
          }
        } catch (e) {
          print('Error parsing response: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting form data: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}