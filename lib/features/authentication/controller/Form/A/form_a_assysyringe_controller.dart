import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:intl/intl.dart';
import 'package:oji_1/common/api.dart';

class FormAAssySyringeController extends GetxController {
  final responses = <String, bool?>{
    "pallet_clean": null,
    "floor_clean": null,
    "under_machine_clean": null,
    "above_machine_clean": null,
    "grill_clean": null,

    "no_product_left": null,
    "no_barrel_left": null,
    "no_plunger_left": null,
    "no_bulk_needle_left": null,
    "no_gasket_left": null,
    "no_component_left": null,
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
  final syringeController = TextEditingController();

  Future<void> submitForm({
    required BuildContext context,
    required int task_id,
    required String codeTask,
    required String tanggal,
    required String sebelumProduk,
    required String sebelumBets,
    required String sebelumSyringe,
    required Map<String, bool?> responses,
    required Map<String, TextEditingController> numericResponses,
  }) async {
    final formData = {
      'task_id': task_id,
      'code_task': codeTask,
      'tanggal': tanggal,
      'sebelum_produk': sebelumProduk,
      'sebelum_bets': sebelumBets,
      'sebelum_needle': sebelumSyringe,

      'bersih_palet': responses['pallet_clean'],
      'bersih_lantai': responses['floor_clean'],
      'bersih_kolong': responses['under_machine_clean'],
      'bersih_mesin': responses['above_machine_clean'],
      'bersih_grill': responses['grill_clean'],

      'sisa_lantai': responses['no_product_left'],
      'sisa_barrel': responses['no_barrel_left'],
      'sisa_plunger': responses['no_plunger_left'],
      'sisa_needle': responses['no_bulk_needle_left'],
      'sisa_gasket': responses['no_gasket_left'],
      'sisa_starwhell': responses['no_component_left'],
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
          "form-a-assy-syringe", formData
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

  Future<void> fetchFormAAssySyringe(String id) async {
    final data = (await Api.get("form-a-assy-syringe/$id"))['data'];
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
    syringeController.text = data['sebelum_needle'] ?? '';

    responses['pallet_clean'] = data['bersih_palet'];
    responses['floor_clean'] = data['bersih_lantai'];
    responses['under_machine_clean'] = data['bersih_kolong'];
    responses['above_machine_clean'] = data['bersih_mesin'];
    responses['grill_clean'] = data['bersih_grill'];

    responses['no_product_left'] = data['sisa_lantai'];
    responses['no_barrel_left'] = data['sisa_barrel'];
    responses['no_plunger_left'] = data['sisa_plunger'];
    responses['no_bulk_needle_left'] = data['sisa_needle'];
    responses['no_gasket_left'] = data['sisa_gasket'];
    responses['no_component_left'] = data['sisa_starwhell'];
    responses['no_output_left'] = data['sisa_box'];
    responses['no_reject_left'] = data['sisa_reject'];
    responses['no_rework_left'] = data['sisa_rework'];

    responses['no_docs_left'] = data['sebelum_dokumen'];
    responses['picking_list'] = data['material_sesuai'];
    responses['document_related'] = data['saat_dokumen'];

    // Set numeric values
    numericResponses['temperature']?.text = (data['suhu']?.toString() ?? '0');
    numericResponses['humidity']?.text = (data['kelembapan']?.toString() ?? '0');

    print(responses);

    update(); // notify UI to refresh
  }
}
