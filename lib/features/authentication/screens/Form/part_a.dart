import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/size.dart';
import '../../models/task_model.dart';

class PartA extends StatefulWidget {
  final Task task;
  const PartA({super.key, required this.task});

  @override
  _PartAState createState() => _PartAState();
}

class _PartAState extends State<PartA> {
  final Map<String, bool?> responses = {
    "floor_clean": null,
    "walls_clean": null,
    "grill_clean": null,
    "tools_clean": null,
    "no_material_left": null,
    "no_docs_left": null,
  };

  final Map<String, TextEditingController> numericResponses = {
    "temperature": TextEditingController(),
    "humidity": TextEditingController(),
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
      body: Column(
        children: [
          // Sticky
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logos/logo_oneject.png', height: 50),
                const SizedBox(height: 10),
                Text(
                  widget.task.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Code: ${widget.task.code}",
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const Divider(thickness: 1),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTranslatedQuestion("Kebersihan line produksi meliputi:", "Cleanliness of the production line includes:"),
                  _buildQuestion("a. Lantai bersih (tidak lengket dan tidak ada genangan air)", "floor_clean", "Floor is clean (not sticky and no water puddles)"),
                  _buildQuestion("b. Dinding dan langit-langit ruangan bersih", "walls_clean", "Walls and ceiling are clean"),
                  _buildQuestion("c. Return grill dalam keadaan bersih", "grill_clean", "Return grill is clean"),
                  _buildQuestion("Kebersihan peralatan dan perlengkapan", "tools_clean", "Cleanliness of tools and equipment"),
                  _buildYesNoQuestion("Tidak ada sisa produk/komponen/material sebelumnya", "no_material_left", "No leftover products/components/materials from the previous batch"),
                  _buildYesNoQuestion("Tidak ada dokumen, catatan, atau label, dari proses produksi sebelumnya", "no_docs_left", "No documents, records, or labels from the previous production process"),
                  _buildYesNoQuestion("Materi sesuai dengan Picking List dan CoA komponen (Tanggal Kadaluarsa, Tanggal Produksi, dan Nama Material)", "materials_match", "Materials match the Picking List and CoA components (Expiration Date, Production Date, and Material Name)"),
                  _buildNumberInputQuestion("Pernyataan Suhu Lingkungan (T)", "temperature", "Environmental Temperature Statement (T)", "°C"),
                  _buildNumberInputQuestion("Pernyataan Kelembapan Relatif (RH)", "humidity", "Relative Humidity Statement (RH)", "%"),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Submit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslatedQuestion(String question, String translation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: question.contains("Kebersihan line produksi meliputi:")
                ? 16
                : 12,
            fontWeight: question.contains("Kebersihan line produksi meliputi:")
                ? FontWeight.bold
                : FontWeight.normal,
            color: question.contains("Kebersihan line produksi meliputi:")
                ? Colors.blue
                : Colors.black,
          ),
        ),
        Text(
          translation,
          style: const TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(String question, String key, String translation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTranslatedQuestion(question, translation),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: responses[key],
                        onChanged: (value) {
                          setState(() {
                            responses[key] = value;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bersih",
                            style: TextStyle(fontSize: 12),
                          ),
                          const Text(
                            "(Clean)",
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: responses[key],
                        onChanged: (value) {
                          setState(() {
                            responses[key] = value;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tidak Bersih",
                            style: TextStyle(fontSize: 12),
                          ),
                          const Text(
                            "(Not Clean)",
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion(String question, String key, String translation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTranslatedQuestion(question, translation),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: responses[key],
                            onChanged: (value) {
                              setState(() {
                                responses[key] = value;
                              });
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ya",
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                "(Yes)",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: responses[key],
                            onChanged: (value) {
                              setState(() {
                                responses[key] = value;
                              });
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tidak",
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                "(No)",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInputQuestion(String question, String key, String translation, String unit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTranslatedQuestion(question, translation),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: numericResponses[key],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5), // Space between input and unit
                  Text(
                    unit, // °C or %
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
