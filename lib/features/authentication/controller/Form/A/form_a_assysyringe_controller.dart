import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormAAssySyringeController extends GetxController {
  Future<void> submitForm({
    required BuildContext context,
    required String codeTask,
    required String tanggal,
    required String sebelumProduk,
    required String sebelumBets,
    required String sebelumSyringe,
    required Map<String, bool?> responses,
    required Map<String, TextEditingController> numericResponses,
  }) async {
    final uri = Uri.parse('http://127.0.0.1:8000/api/form-a-assy-syringe');

    final formData = {
      'code_task': codeTask,
      'tanggal': tanggal,
      'sebelum_produk': sebelumProduk,
      'sebelum_bets': sebelumBets,
      'sebelum_syringe': sebelumSyringe,

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
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 201) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Success",
            text: "Form submitted successfully!",
          ),
        );
      } else {
        final body = jsonDecode(response.body);
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Error",
            text: "Submission failed: ${body['error'] ?? response.body}",
          ),
        );
      }
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
}
