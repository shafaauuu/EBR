import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import '../../../../../common/api.dart';

class FormEInjectionController extends GetxController {
  final jmlTeoritis = 0.obs;
  final jmlRelease = 0.obs;
  final jmlKarantina = 0.obs;
  final jmlReject = 0.obs;
  final jmlSisa = 0.obs;
  final sampleIpc = 0.obs;
  final sampleQc = 0.obs;
  final sampleRelease = 0.obs;
  final hasilYield = 0.obs;
  final totalHasil = 0.obs;

  FormEInjectionController() {
    // Listen to changes in relevant fields and update total
    ever(jmlReject, (_) => _calculateTotal());
    ever(jmlSisa, (_) => _calculateTotal());
    ever(sampleRelease, (_) => _calculateTotal());
    ever(hasilYield, (_) => _calculateTotal());
  }

  void _calculateTotal() {
    totalHasil.value = (jmlReject.value + jmlSisa.value + sampleRelease.value + hasilYield.value);
  }

  Future<void> submitForm({
    required BuildContext context,
    required int task_id,
    required String codeTask,
  }) async {
    final formData = {
      'task_id': task_id,
      'code_task': codeTask,
      'jml_teoritis': jmlTeoritis.value,
      'jml_release': jmlRelease.value,
      'jml_karantina': jmlKarantina.value,
      'jml_reject': jmlReject.value,
      'jml_sisa': jmlSisa.value,
      'sample_ipc': sampleIpc.value,
      'sample_qc': sampleQc.value,
      'sample_release': sampleRelease.value,
      'yield': hasilYield.value,
      'total_hasil': totalHasil.value,
    };


    try {
      final response = await Api.post("form-e-injection", formData);


        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Success",
            text: "Form submitted successfully.",
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

  Future<void> fetchFormEInjection(String id) async {
    final data = (await Api.get("form-e-injection/$id"))['data'];

    jmlTeoritis.value = data['jml_teoritis'] ?? 0;
    jmlRelease.value = data['jml_release'] ?? 0;
    jmlKarantina.value = data['jml_karantina'] ?? 0;
    jmlReject.value = data['jml_reject'] ?? 0;
    jmlSisa.value = int.tryParse(data['jml_sisa'].toString()) ?? 0;
    sampleIpc.value = data['sample_ipc'] ?? 0;
    sampleQc.value = data['sample_qc'] ?? 0;
    sampleRelease.value = data['sample_release'] ?? 0;
    hasilYield.value = int.tryParse(data['yield'].toString()) ?? 0;
    totalHasil.value = data['total_hasil'] ?? 0;

    print(data);

    update(); // notify UI to refresh
  }
}
