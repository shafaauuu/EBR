import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:intl/intl.dart';
import '../../../../../common/api.dart';

class FormANeedleassyController extends GetxController {
  final responses = <String, bool?>{
    "pallet_clean": null,
    "floor_clean": null,
    "under_machine_clean": null,
    "above_machine_clean": null,
    "grill_clean": null,

    "no_product_left": null,
    "no_hub_left": null,
    "no_cap_left": null,
    "no_cannula_left": null,
    "no_output_left": null,
    "no_reject_left": null,
    "no_rework_left": null,

    "no_docs_left": null,
    "picking_list": null,
    "document_related": null,
  }.obs;

  final numericResponses = <String, TextEditingController>{
    'temperature': TextEditingController(),
    'humidity': TextEditingController(),
  };

  final dateController = TextEditingController();
  final productNameController = TextEditingController();
  final batchController = TextEditingController();
  final needleController = TextEditingController();
  final capController = TextEditingController();

  Future<void> submitForm({
    required BuildContext context,
    required int task_id,
    required String codeTask,
    required String tanggal,
    required String sebelumProduk,
    required String sebelumBets,
    required String sebelumNeedle,
    required String sebelumCap,
    required Map<String, bool?> responses,
    required Map<String, TextEditingController> numericResponses,
  }) async {
    // Initial form data
    final formData = {
      'task_id': task_id,
      'code_task': codeTask,
      'tanggal': tanggal,
      'sebelum_produk': sebelumProduk,
      'sebelum_bets': sebelumBets,
      'sebelum_needle': sebelumNeedle,
      'sebelum_cap': sebelumCap,

      'bersih_palet': responses['pallet_clean'],
      'bersih_lantai': responses['floor_clean'],
      'bersih_kolong': responses['under_machine_clean'],
      'bersih_mesin': responses['above_machine_clean'],
      'bersih_grill': responses['grill_clean'],

      'sisa_lantai': responses['no_product_left'],
      'sisa_hub': responses['no_hub_left'],
      'sisa_cap': responses['no_cap_left'],
      'sisa_canula': responses['no_cannula_left'],
      'sisa_box': responses['no_output_left'],
      'sisa_reject': responses['no_reject_left'],
      'sisa_rework': responses['no_rework_left'],

      'sebelum_dokumen': responses['no_docs_left'],
      'material_sesuai': responses['picking_list'],
      'saat_dokumen': responses['document_related'],

      'suhu': double.tryParse(numericResponses['temperature']?.text ?? '0') ?? 0.0,
      'kelembapan': double.tryParse(numericResponses['humidity']?.text ?? '0') ?? 0.0,
    };

    try {
      final response = await Api.post(
          "form-a-needle-assy", formData
      );

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Form submitted successfully!",
        ),
      );
    } catch (e) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Exception",
          text: "An error occurred: $e",
        ),
      );
    }
  }

  Future<void> fetchFormANeedleAssy(String id) async {
    final data = (await Api.get("form-a-needle-assy/$id"))['data'];
    // convert from 2025-04-30T17:00:00.000000Z = dd/mm/yyyy
    String rawDate = data['tanggal'] ?? '';
    if (rawDate.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(rawDate);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      dateController.text = formattedDate;
    } else {
      dateController.text = '';
    }
    productNameController.text = data['sebelum_produk'] ?? '';
    batchController.text = data['sebelum_bets'] ?? '';
    needleController.text = data['sebelum_needle'] ?? '';
    capController.text = data['sebelum_cap'] ?? '';

    responses['pallet_clean'] = data['bersih_palet'];
    responses['floor_clean'] = data['bersih_lantai'];
    responses['under_machine_clean'] = data['bersih_kolong'];
    responses['above_machine_clean'] = data['bersih_mesin'];
    responses['grill_clean'] = data['bersih_grill'];

    responses['no_product_left'] = data['sisa_lantai'];
    responses['no_hub_left'] = data['sisa_hub'];
    responses['no_cap_left'] = data['sisa_cap'];
    responses['no_cannula_left'] = data['sisa_canula'];
    responses['no_output_left'] = data['sisa_box'];
    responses['no_reject_left'] = data['sisa_reject'];
    responses['no_rework_left'] = data['sisa_rework'];

    responses['no_docs_left'] = data['sebelum_dokumen'];
    responses['picking_list'] = data['material_sesuai'];
    responses['document_related'] = data['saat_dokumen'];

    numericResponses['temperature']?.text = data['suhu']?.toString() ?? '';
    numericResponses['humidity']?.text = data['kelembapan']?.toString() ?? '';

    print(responses);

    update();
  }
}
