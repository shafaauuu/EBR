import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import 'package:intl/intl.dart';
import '../../../../../common/api.dart';

class FormAInjectionController extends GetxController {
  final responses = <String, bool?>{
    'floor_clean': false,
    'walls_clean': false,
    'grill_clean': false,
    'tools_clean': false,
    'no_material_left': false,
    'no_docs_left': false,
    'picking_list': false,
    'document_related': false,
  }.obs;

  final numericResponses = <String, TextEditingController>{
    'temperature': TextEditingController(),
    'humidity': TextEditingController(),
  };

  final dateController = TextEditingController();
  final productNameController = TextEditingController();
  final batchController = TextEditingController();

  Future<void> submitForm({
    required BuildContext context,
    required int task_id,
    required String codeTask,
    required String tanggal,
    required String sebelumProduk,
    required String sebelumBets,
    required Map<String, bool?> responses,
    required Map<String, TextEditingController> numericResponses,
  }) async {

    final formData = {
      'task_id': task_id,
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
      final response = await Api.post(
          "form-a-injection", formData
      );
      // Show success dialog
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Form submitted successfully!",
        ),
      );

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

  Future<void> fetchFormAInjection(String id) async {
    final data = (await Api.get("form-a-injection/$id"))['data'];
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

    responses['floor_clean'] = data['bersih_lantai'];
    responses['walls_clean'] = data['bersih_dinding'];
    responses['grill_clean'] = data['bersih_grill'];
    responses['tools_clean'] = data['bersih_alat'];
    responses['no_material_left'] = data['sisa_produk'];
    responses['no_docs_left'] = data['sebelum_dokumen'];
    responses['picking_list'] = data['material_sesuai'];
    responses['document_related'] = data['saat_dokumen'];

    numericResponses['temperature']?.text = data['suhu']?.toString() ?? '';
    numericResponses['humidity']?.text = data['kelembapan']?.toString() ?? '';
    print(responses);

    update(); // notify UI to refresh
  }
}