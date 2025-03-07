import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';

class PartB extends StatefulWidget {
  final Task task;

  const PartB({super.key, required this.task});

  @override
  _PartBState createState() => _PartBState();
}

class _PartBState extends State<PartB> {
  Map<String, String?> selectedValues = {}; // Allowing null values

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part B. Persiapan dan Inspeksi Mesin"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header
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
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
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
              Text(
                "Mesin/Perlengkapan",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInspectionItem("Sumitomo 11"),
              _buildInspectionItem("Mold Barrel DS 1mL HRT"),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionItem(String itemName) {
    String key = itemName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio<String?>(
                        value: "Terkualifikasi",
                        groupValue: selectedValues[key], // Initially null
                        onChanged: (value) {
                          setState(() {
                            selectedValues[key] = value;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Kualifikasi",
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            "(Qualified)",
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
                      Radio<String?>(
                        value: "Tidak Terkualifikasi",
                        groupValue: selectedValues[key], // Initially null
                        onChanged: (value) {
                          setState(() {
                            selectedValues[key] = value;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tidak Terkualifikasi",
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            "(Not Qualified)",
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
                      Radio<String?>(
                        value: "N/A",
                        groupValue: selectedValues[key], // Initially null
                        onChanged: (value) {
                          setState(() {
                            selectedValues[key] = value;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "N/A",
                            style: TextStyle(fontSize: 12),
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
        const Divider(),
      ],
    );
  }
}
