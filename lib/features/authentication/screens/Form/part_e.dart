import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';

class PartE extends StatefulWidget {
  final Task? task;

  const PartE({super.key, this.task});

  @override
  _PartEState createState() => _PartEState();
}

class _PartEState extends State<PartE> {
  final List<Map<String, String>> sentences = [
    {"no": "1", "text": "Jumlah Awal Assembling (produk rilis) (a)", "label": "unit/pcs"},
    {"no": "2", "text": "Jumlah Produk Karantina Assembling yang telah bersatu rilis (b)", "label": "unit/pcs"},
    {"no": "3", "text": "Total Bulk Syringe Siap Blister (c) c = a + b", "label": "unit/pcs"},
    {"no": "4", "text": "Jumlah finished goods rilis (d)", "label": "unit/pcs"},
    {"no": "5.A.", "text": "Jumlah produk karantina di tahap Blister-Packing (e)", "label": "unit/pcs"},
    {"no": "5.B.", "text": "Jumlah reject di tahap Blister-Packing (f)", "label": "unit/pcs"},
    {"no": "5.C.", "text": "Jumlah reject di tahap Blister-Packing yang dimusnahkan (g)", "label": "unit/pcs"},
    {"no": "6.A.", "text": "Sampel IPC (diisi QC)", "label": "unit/pcs"},
    {"no": "6.B.", "text": "Sampel QC (diisi QC)", "label": "unit/pcs"},
    {"no": "6.C.", "text": "Sampel (released) untuk keperluan lain/tidak dikembalikan ke Line (h)", "label": "unit/pcs"},
    {"no": "7", "text": "Hasil / Yield Blister (i)", "label": "% (persen)"},
    {"no": "8", "text": "Total hasil produksi di tahap Blister-Packing ( d + e + f + g )", "label": "unit/pcs"},
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
                      _buildAlignedText("BRM No.", ""),
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
                  _buildProductSummaryTable(),
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

  Widget _buildProductSummaryTable() {
    return Table(
      border: TableBorder.all(color: Colors.black26, width: 1.0),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(4),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _buildTableHeaderCell("No."),
            _buildTableHeaderCell("Remarks"),
            _buildTableHeaderCell("Amount"),
          ],
        ),
        ...sentences.map((row) {
          return TableRow(
            children: [
              _buildTableCell(row["no"]!, isCentered: true),
              _buildTableCell(row["text"]!),
              _buildTableInput(row["label"]!),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isCentered = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: isCentered ? Center(child: Text(text)) : Text(text),
    );
  }

  Widget _buildTableInput(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        ),
      ),
    );
  }
}
