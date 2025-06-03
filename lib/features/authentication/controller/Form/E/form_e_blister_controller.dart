import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import '../../../../../common/api.dart';

class FormEBlisterController extends GetxController {
  final jmlAwalAssy = 0.obs;
  final jmlKarantinaAssy = 0.obs;
  final totalSyringe = 0.obs;
  final jmlFG = 0.obs;
  final jmlKarantina = 0.obs;
  final jmlReject = 0.obs;
  final jmlSisa = 0.obs;
  final sampleIPC = 0.obs;
  final sampleQC = 0.obs;
  final sampleReleased = 0.obs;
  final yieldValue = 0.obs;
  final totalProd = 0.obs;

  Future<void> submitForm({
    required BuildContext context,
    required int task_id,
    required String codeTask,
  }) async {final formData = {
    'task_id': task_id,
    'code_task': codeTask,
    'jml_awal_assy': jmlAwalAssy.value,
    'jml_karantina_assy': jmlKarantinaAssy.value,
    'total_syringe': totalSyringe.value,
    'jml_fg': jmlFG.value,
    'jml_karantina': jmlKarantina.value,
    'jml_reject': jmlReject.value,
    'jml_sisa': jmlSisa.value,
    'sample_ipc': sampleIPC.value,
    'sample_qc': sampleQC.value,
    'sample_released': sampleReleased.value,
    'yield': yieldValue.value,
    'total_prod': totalProd.value,
  };

    try {
      final response = await Api.post("form-e-blister", formData);

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Form E Blister submitted successfully!",
        ),
      );

    } catch (e) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "An error occurred: $e",
        ),
      );
    }
  }

  Future<void> fetchFormEBlister(String id) async {
    final data = (await Api.get("form-e-blister/$id"))['data'];

    // Populate observables with the fetched data
    jmlAwalAssy.value = data['jml_awal_assy'] ?? 0;
    jmlKarantinaAssy.value = data['jml_karantina_assy'] ?? 0;
    totalSyringe.value = data['total_syringe'] ?? 0;
    jmlFG.value = data['jml_fg'] ?? 0;
    jmlKarantina.value = data['jml_karantina'] ?? 0;
    jmlReject.value = data['jml_reject'] ?? 0;
    jmlSisa.value = data['jml_sisa'] ?? 0;
    sampleIPC.value = data['sample_ipc'] ?? 0;
    sampleQC.value = data['sample_qc'] ?? 0;
    sampleReleased.value = data['sample_released'] ?? 0;
    yieldValue.value = int.tryParse(data['yield'].toString()) ?? 0;
    totalProd.value = data['total_prod'] ?? 0;

    print(data);

    update(); // notify UI to refresh
  }
}
