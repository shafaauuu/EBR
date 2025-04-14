import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/size.dart';
import '../../../models/task_model.dart';
import '../../../controller/task_details_controller.dart';

class PartB extends StatefulWidget {
  final Task task;

  const PartB({super.key, required this.task});

  @override
  _PartBState createState() => _PartBState();
}

class _PartBState extends State<PartB> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  Map<String, String?> selectedValues = {}; // Allowing null values

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part B. Persiapan dan Inspeksi Mesin dan Perlengkapan"),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // First column: Logo
                    SizedBox(
                      width: 250,
                      child: Image.asset('assets/logos/logo_oneject.png', height: 50),
                    ),

                    const SizedBox(width: 16), // Small spacing between columns

                    // Second column: Code & Name
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "BATCH RECORD",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildAlignedText("P/C Code", widget.task.code),
                          _buildAlignedText("P/C Name", widget.task.name),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16), // Small spacing between columns

                    // Third column: BRM, Rev No, Eff. Date
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Obx(() => _buildAlignedText("BRM No.", controller.selectedBRM.value)),
                          _buildAlignedText("Rev No.", ""),
                          _buildAlignedText("Eff. Date", ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),

              const SizedBox(height: Sizes.spaceBtwItems),
              Text(
                "Mesin/Perlengkapan",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Machine/Tools",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              _buildInspectionTable(),

              const SizedBox(height: Sizes.spaceBtwItems),
              const Divider(),

              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlignedText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100, // Fixed width for label to align colons
          child: Text(
            "$label :",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Blister Pack Hualian 1",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRadioOptions("Blister Pack Hualian 1"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Blister Pack Hualian 2",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRadioOptions("Blister Pack Hualian 1"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOptions(String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSingleRadioOption(key, "Terkualifikasi", "(Qualified)"),
        _buildSingleRadioOption(key, "Tidak Terkualifikasi", "(Not Qualified)"),
        _buildSingleRadioOption(key, "N/A", "N/A"),
      ],
    );
  }

  Widget _buildSingleRadioOption(String key, String value, String translation) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String?>(
          value: value,
          groupValue: selectedValues[key],
          onChanged: (selected) {
            setState(() {
              selectedValues[key] = selected;
            });
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              translation,
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12), // Spacing between radio options
      ],
    );
  }

}
