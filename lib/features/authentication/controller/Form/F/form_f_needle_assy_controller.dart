import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../common/api.dart';
import '../../../models/task_model.dart';

class FormFNeedleAssyController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // For storing form data
  final taskId = RxInt(0);
  final taskCode = ''.obs;

  // For image files
  Rx<File?> labelMesin = Rx<File?>(null);
  Rx<File?> label2 = Rx<File?>(null);

  // For existing form data
  final existingFormData = Rx<Map<String, dynamic>?>(null);

  void setTaskInfo(Task task) {
    taskId.value = task.id;
    taskCode.value = task.code;

    // Fetch existing data if available
    fetchFormByTaskId(task.id);
  }

  void setLabelMesin(File file) {
    labelMesin.value = file;
  }

  void setLabel2(File file) {
    label2.value = file;
  }

  Future<void> fetchFormByTaskId(int taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/form-f-needle-assy/$taskId?is_task_id=true');

      final response = await http.get(
        uri,
        headers: Api.buildHeader(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['data'] != null) {
        if (jsonResponse['data'] is List && jsonResponse['data'].isNotEmpty) {
          existingFormData.value = jsonResponse['data'][0];
        }
      }
    } catch (e) {
      errorMessage.value = 'Error fetching form data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitForm() async {
    if (labelMesin.value == null || label2.value == null) {
      errorMessage.value = 'Please upload both required images';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/form-f-needle-assy');

      var request = http.MultipartRequest('POST', uri);

      // Add headers from Api.buildHeader()
      final headers = Api.buildHeader();
      headers.remove('Content-Type'); // Remove Content-Type as it will be set by MultipartRequest
      request.headers.addAll(headers);

      // Add text fields
      request.fields['task_id'] = taskId.value.toString();
      request.fields['task_code'] = taskCode.value;

      // Add files
      if (labelMesin.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'label_mesin',
          labelMesin.value!.path,
        ));
      }

      if (label2.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'label_2',
          label2.value!.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        successMessage.value = 'Form submitted successfully';
        // Update existing form data with the newly created form
        if (jsonResponse['data'] != null) {
          existingFormData.value = jsonResponse['data'];
        }
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = jsonResponse['message'] ?? 'Failed to submit form';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> updateForm(String formId) async {
    if (labelMesin.value == null && label2.value == null) {
      errorMessage.value = 'Please upload at least one image to update';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/form-f-needle-assy/$formId');

      var request = http.MultipartRequest('POST', uri);

      // Add headers from Api.buildHeader()
      final headers = Api.buildHeader();
      headers.remove('Content-Type'); // Remove Content-Type as it will be set by MultipartRequest
      request.headers.addAll(headers);

      // Add method override for PUT
      request.fields['_method'] = 'PUT';

      // Add text fields
      request.fields['task_code'] = taskCode.value;

      // Add files only if they were updated
      if (labelMesin.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'label_mesin',
          labelMesin.value!.path,
        ));
      }

      if (label2.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'label_2',
          label2.value!.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        successMessage.value = 'Form updated successfully';
        // Update existing form data with the updated form
        if (jsonResponse['data'] != null) {
          existingFormData.value = jsonResponse['data'];
        }
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = jsonResponse['message'] ?? 'Failed to update form';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> deleteForm(String formId) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/form-f-needle-assy/$formId');

      final response = await http.delete(
        uri,
        headers: Api.buildHeader(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        successMessage.value = 'Form deleted successfully';
        // Clear existing form data
        existingFormData.value = null;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = jsonResponse['message'] ?? 'Failed to delete form';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }
}