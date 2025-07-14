import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:oji_1/common/api.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormGNeedleAssyController extends GetxController {
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

  // Raw base64 strings for signatures
  Rx<String?> rawSignature1 = Rx<String?>(null);
  Rx<String?> rawSignature2 = Rx<String?>(null);
  Rx<String?> rawSignature3 = Rx<String?>(null);

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

      var url = Uri.parse('${ApiConfig.baseUrl}/form-g-needle-assy');

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
            text: "Form G Needle Assy submitted successfully",
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

      // Make API request
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/form-g-needle-assy/$taskId?is_task_id=true'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          print('Form G response received');

          if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
            var formData = jsonResponse['data'][0];
            print('Processing form data for ID: ${formData['id']}');

            // Process signature 1
            if (formData['has_signed_1'] == true && formData['signed_1'] != null) {
              print('Found signature 1');
              
              // Store the raw base64 string directly
              rawSignature1.value = formData['signed_1'];
              
              // Don't try to decode here - we'll handle it in the UI
              print('Stored raw signature 1');
            } else {
              print('No signature 1 found or has_signed_1 is false');
            }

            // Process signature 2
            if (formData['has_signed_2'] == true && formData['signed_2'] != null) {
              print('Found signature 2');
              
              // Store the raw base64 string directly
              rawSignature2.value = formData['signed_2'];
              
              // Don't try to decode here - we'll handle it in the UI
              print('Stored raw signature 2');
            } else {
              print('No signature 2 found or has_signed_2 is false');
            }

            // Process signature 3
            if (formData['has_signed_3'] == true && formData['signed_3'] != null) {
              print('Found signature 3');
              
              // Store the raw base64 string directly
              rawSignature3.value = formData['signed_3'];
              
              // Don't try to decode here - we'll handle it in the UI
              print('Stored raw signature 3');
            } else {
              print('No signature 3 found or has_signed_3 is false');
            }

            // Set other form values
            remarks.value = formData['remarks'] ?? '';
            inisial1.value = formData['inisial_1'] ?? '';
            inisial2.value = formData['inisial_2'] ?? '';
            inisial3.value = formData['inisial_3'] ?? '';

            return formData;
          } else {
            print('No form data found for task ID: $taskId');
          }
        } catch (e) {
          print('Error parsing response: $e');
          return null;
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
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