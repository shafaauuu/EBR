import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Form/E/form_e_blister_controller.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class PartE_Blister extends StatefulWidget {
  final Task task;

  const PartE_Blister({super.key, required this.task});

  @override
  _PartE_BlisterState createState() => _PartE_BlisterState();
}

class _PartE_BlisterState extends State<PartE_Blister> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final FormEBlisterController formController = Get.put(FormEBlisterController());
  int counter = 0;

  final String role = "Production Operation";

  final List<Map<String, String>> sentences = [
    {"no": "1", "text": "Jumlah Awal Assembling (produk rilis) (a)", "label": "unit/pcs", "key": "jml_teoritis"},
    {"no": "2", "text": "Jumlah Produk Karantina Assembling yang telah bersatu rilis (b)", "label": "unit/pcs"},
    {"no": "3", "text": "Total Bulk Syringe Siap Blister (c) c = a + b", "label": "unit/pcs"},
    {"no": "4", "text": "Jumlah finished goods rilis (d)", "label": "unit/pcs"},
    {"no": "5.A.", "text": "Jumlah produk karantina di tahap Blister-Packing (e)", "label": "unit/pcs"},
    {"no": "5.B.", "text": "Jumlah reject di tahap Blister-Packing (f)", "label": "unit/pcs"},
    {"no": "5.C.", "text": "Jumlah reject di tahap Blister-Packing yang dimusnahkan (g)", "label": "unit/pcs"},
    {"no": "6.A.", "text": "Sampel IPC (diisi QC)", "label": "unit/pcs", "key": "sample_ipc"},
    {"no": "6.B.", "text": "Sampel QC (diisi QC)", "label": "unit/pcs", "key": "sample_qc"},
    {"no": "6.C.", "text": "Sampel (released) untuk keperluan lain/tidak dikembalikan ke Line (h)", "label": "unit/pcs", "key": "sample_release"},
    {"no": "7", "text": "Hasil / Yield Blister (i)", "label": "% (persen)", "key": "yield"},
    {"no": "8", "text": "Total hasil produksi di tahap Blister-Packing ( d + e + f + g )", "label": "unit/pcs", "key": "total_hasil"},
  ];

  @override
  void initState() {
    super.initState();
    check();
  }
  void check() async {
    final controller = Get.put(FormEBlisterController());
    await controller.fetchFormEBlister(widget.task.id.toString());
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
                      _buildAlignedText("P/C Code", widget.task.code ?? ""),
                      _buildAlignedText("P/C Name", widget.task.name ?? ""),
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
                        formController.submitForm(
                          context: context, // Pass the BuildContext
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
    );
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
        bool isQCField = row["no"] == "6.A." || row["no"] == "6.B.";
        bool isEnabled = !(isQCField && role != "Quality Control");

        // Map 'no' to the controller observable
        RxInt fieldValue;
        switch (row["no"]) {
          case "1":
            fieldValue = formController.jmlAwalAssy;
            break;
          case "2":
            fieldValue = formController.jmlKarantinaAssy;
            break;
          case "3":
            fieldValue = formController.totalSyringe;
            break;
          case "4":
            fieldValue = formController.jmlFG;
            break;
          case "5.A.":
            fieldValue = formController.jmlKarantina;
            break;
          case "5.B.":
            fieldValue = formController.jmlReject;
            break;
          case "5.C.":
            fieldValue = formController.jmlSisa;
            break;
          case "6.A.":
            fieldValue = formController.sampleIPC;
            break;
          case "6.B.":
            fieldValue = formController.sampleQC;
            break;
          case "6.C.":
            fieldValue = formController.sampleReleased;
            break;
          case "7":
            fieldValue = formController.yieldValue;
            break;
          case "8":
            fieldValue = formController.totalProd;
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
