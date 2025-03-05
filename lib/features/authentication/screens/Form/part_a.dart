import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';

class PartAPage extends StatefulWidget {
  final Task task;
  const PartAPage({super.key, required this.task});

  @override
  _PartAPageState createState() => _PartAPageState();
}

class _PartAPageState extends State<PartAPage> {
  final Map<String, bool?> responses = {
    "floor_clean": null,
    "walls_clean": null,
    "grill_clean": null,
    "tools_clean": null,
    "no_material_left": null,
    "no_docs_left": null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part A. Line Clearance"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logos/logo_oneject.png', height: 50),
                const SizedBox(height: 10),
                Text(
                  widget.task.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Code: ${widget.task.code}",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(thickness: 1),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildQuestion("Lantai bersih (tidak lengket/tidak ada genangan air)", "floor_clean"),
                  _buildQuestion("Dinding dan langit-langit ruangan bersih", "walls_clean"),
                  _buildQuestion("Return grill dalam kondisi bersih", "grill_clean"),
                  _buildQuestion("Kebersihan peralatan dan perlengkapan", "tools_clean"),
                  _buildQuestionYesNo("Tidak ada sisa produk/komponen/material sebelumnya", "no_material_left"),
                  _buildQuestionYesNo("Tidak ada dokumen/catatan/label dari proses produksi sebelumnya", "no_docs_left"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.snackbar("Success", "Part A submitted!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white);
                Get.back();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question, style: const TextStyle(fontSize: 16))),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: responses[key],
                onChanged: (value) => setState(() => responses[key] = value),
              ),
              const Text("Bersih"),
              const SizedBox(width: 10),
              Radio<bool>(
                value: false,
                groupValue: responses[key],
                onChanged: (value) => setState(() => responses[key] = value),
              ),
              const Text("Tidak"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionYesNo(String question, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question, style: const TextStyle(fontSize: 16))),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: responses[key],
                onChanged: (value) => setState(() => responses[key] = value),
              ),
              const Text("Ya"),
              const SizedBox(width: 10),
              Radio<bool>(
                value: false,
                groupValue: responses[key],
                onChanged: (value) => setState(() => responses[key] = value),
              ),
              const Text("Tidak"),
            ],
          ),
        ],
      ),
    );
  }
}
