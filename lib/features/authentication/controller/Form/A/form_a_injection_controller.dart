import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FormAInjectionController extends GetxController {
  Future<void> submitForm({
    required BuildContext context,
    required String codeTask,
    required String tanggal,
    required String sebelumProduk,
    required String sebelumBets,
    required Map<String, bool?> responses,
    required Map<String, TextEditingController> numericResponses,
  }) async {
    final uri = Uri.parse('http://127.0.0.1:8000/api/form-a-injection');

    final formData = {
      'code_task': codeTask,
      'tanggal': tanggal,
      'sebelum_produk': sebelumProduk,
      'sebelum_bets': sebelumBets,

      'bersih_lantai': responses['floor_clean'],
      'bersih_dinding': responses['walls_clean'],
      'bersih_grill': responses['grill_clean'],
      'bersih_alat': responses['tools_clean'],
      'sisa_produk': responses['no_material_left'],

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
        // Show success dialog
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
        // Show error dialog
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
      // Show exception dialog
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