import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class PartE extends StatefulWidget {
  final Task? task;

  const PartE({super.key, this.task});

  @override
  _PartEState createState() => _PartEState();
}

class _PartEState extends State<PartE> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  final String role = "Production Operation";

  final List<Map<String, String>> sentences = [
    {"no": "1", "text": "Jumlah Teoritis (a)", "label": "unit/pcs"},
    {"no": "2", "text": "Jumlah Finished Goods Rilis (b)", "label": "unit/pcs"},
    {"no": "3.A.", "text": "Jumlah produk karantina di tahap Blister-Packing (c)", "label": "unit/pcs"},
    {"no": "3.B.", "text": "Jumlah reject di tahap Blister-Packing (d)", "label": "unit/pcs"},
    {"no": "3.C.", "text": "Jumlah sisa di tahap Blister-Packing yang dimusnahkan (e)", "label": "unit/pcs"},
    {"no": "4.A.", "text": "Sampel IPC (diisi QC)", "label": "unit/pcs"},
    {"no": "4.B.", "text": "Sampel QC (diisi QC)", "label": "unit/pcs"},
    {"no": "4.C.", "text": "Sampel (released) untuk keperluan lain/tidak dikembalikan ke Line (f)", "label": "unit/pcs"},
    {"no": "7", "text": "Hasil / Yield Blister (g)", "label": "% (persen)"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part E. Product Summary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Sticky Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First column: Logo
                SizedBox(
                  width: 250,
                  child: Image.asset('assets/logos/logo_oneject.png', height: 50),
                ),
                const SizedBox(width: 16),

                // Second column: Code & Name
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BATCH RECORD",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildAlignedText("P/C Code", widget.task?.code ?? ""),
                      _buildAlignedText("P/C Name", widget.task?.name ?? ""),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Third column: BRM, Rev No, Eff. Date
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

          // Wrap the scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductSummaryList(),
                  const SizedBox(height: 16),
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
        ],
      ),
    ); // <-- This closing bracket was missing
  }

  Widget _buildAlignedText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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

  Widget _buildProductSummaryList() {
    return Column(
      children: sentences.map((row) {
        bool isQCField = (row["no"] == "6.A." || row["no"] == "6.B.");
        bool isEnabled = !(isQCField && role != "Quality Control");

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle Number
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      row["no"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Description and Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row["text"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        style: isQCField
                            ? const TextStyle(color: Colors.blue)
                            : null,
                        decoration: InputDecoration(
                          labelText: row["label"],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          // Gray background if disabled
                          filled: !isEnabled,
                          fillColor: !isEnabled ? Colors.grey[200] : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}
