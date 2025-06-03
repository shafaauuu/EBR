import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/controller/Form/E/form_e_needleassy_controller.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class PartE_NeedleAssy extends StatefulWidget {
  final Task task;

  const PartE_NeedleAssy({super.key, required this.task});

  @override
  _PartE_NeedleAssyState createState() => _PartE_NeedleAssyState();
}

class _PartE_NeedleAssyState extends State<PartE_NeedleAssy> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final formEController = Get.put(FormENeedleAssyController());
  int counter = 0;

  final String role = "Production Operation";

  final List<Map<String, String>> sentences = [
    {"no": "1", "text": "Jumlah Teoritis (a)", "label": "unit/pcs", "key": "jml_teoritis"},
    {"no": "2", "text": "Jumlah Finished Goods Rilis (b)", "label": "unit/pcs", "key": "jml_release"},
    {"no": "3.A.", "text": "Jumlah produk karantina di tahap Blister-Packing (c)", "label": "unit/pcs", "key": "jml_karantina"},
    {"no": "3.B.", "text": "Jumlah reject di tahap Blister-Packing (d)", "label": "unit/pcs",  "key": "jml_reject"},
    {"no": "3.C.", "text": "Jumlah sisa di tahap Blister-Packing yang dimusnahkan (e)", "label": "unit/pcs", "key": "jml_sisa"},
    {"no": "4.A.", "text": "Sampel IPC (diisi QC)", "label": "unit/pcs", "key": "sample_ipc"},
    {"no": "4.B.", "text": "Sampel QC (diisi QC)", "label": "unit/pcs", "key": "sample_qc"},
    {"no": "4.C.", "text": "Sampel (released) untuk keperluan lain/tidak dikembalikan ke Line (f)", "label": "unit/pcs", "key": "sample_release"},
    {"no": "5", "text": "Hasil / Yield Blister (g)", "label": "% (persen)", "key": "yield"},
    {"no": "6", "text": "Total hasil produksi di tahap Blister-Packing ( d + e + f + g )", "label": "unit/pcs", "key": "total_hasil"},
  ];

  @override
  void initState() {
    super.initState();
    check();
  }
  void check() async {
    final controller = Get.put(FormENeedleAssyController());
    await controller.fetchFormENeedleAssy(widget.task.id.toString());
    setState(() {
      counter++;
    }); // triggers rebuild


  }

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
                      _buildAlignedText("BRM No.", widget.task.brmNo ?? ""),
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
                      onPressed: () {
                        formEController.submitForm(
                          context: context,
                          task_id: widget.task.id,
                          codeTask: widget.task.code,
                        );
                      },
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
        bool isQCField = (row["no"] == "4.A." || row["no"] == "4.B.");
        bool isEnabled = !(isQCField && role != "Quality Control");

        // Map 'no' to the controller observable
        RxInt fieldValue;
        switch (row["no"]) {
          case "1":
            fieldValue = formEController.jmlTeoritis;
            break;
          case "2":
            fieldValue = formEController.jmlRelease;
            break;
          case "3.A.":
            fieldValue = formEController.jmlKarantina;
            break;
          case "3.B.":
            fieldValue = formEController.jmlReject;
            break;
          case "3.C.":
            fieldValue = formEController.jmlSisa;
            break;
          case "4.A.":
            fieldValue = formEController.sampleIpc;
            break;
          case "4.B.":
            fieldValue = formEController.sampleQc;
            break;
          case "4.C.":
            fieldValue = formEController.sampleRelease;
            break;
          case "5":
            fieldValue = formEController.hasilYield;
            break;
          case "6":
            fieldValue = formEController.totalHasil;
            break;
          default:
            fieldValue = 0.obs;
        }

        List<Widget> children = [];

        // Show image only for "yield"
        if (row["key"] == "yield") {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.asset(
                'assets/images/yield_form_e.jpeg',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        // The main card
        children.add(
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["text"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final text = fieldValue.value == 0 ? '' : fieldValue.value.toString();
                                final controller = TextEditingController(text: text);
                                if (text.isNotEmpty) {
                                  controller.selection = TextSelection.collapsed(offset: text.length);
                                }

                                // For total field (no. 6), make it read-only
                                if (row["no"] == "6") {
                                  return TextFormField(
                                    enabled: false,
                                    controller: controller,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.grey[200], // Light gray background to indicate it's not editable
                                    ),
                                  );

                                }

                                return TextFormField(
                                  enabled: isEnabled,
                                  keyboardType: TextInputType.number,
                                  controller: controller,
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    if (parsed != null) fieldValue.value = parsed;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(row["label"] ?? "")
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }).toList(),
    );
  }

}
