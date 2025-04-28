import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class PartC_Blister extends StatefulWidget {
  final Task task;
  const PartC_Blister({super.key, required this.task});

  @override
  _PartC_BlisterState createState() => _PartC_BlisterState();
}

class _PartC_BlisterState extends State<PartC_Blister> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  //dropdown items
  final List<Map<String, String>> materials = [
    {"name": "Syringe 5ml", "code": "SYR-005", "uom": "PCS", "reqQty": "1000"},
    {"name": "Syringe 10ml", "code": "SYR-010", "uom": "PCS", "reqQty": "500"},
    {"name": "Needle 22G", "code": "NDL-022", "uom": "PCS", "reqQty": "800"},
    {"name": "Film Blister", "code": "FLM-001", "uom": "ROLL", "reqQty": "50"},
    {"name": "Paper Sterile", "code": "PPR-001", "uom": "ROLL", "reqQty": "30"},
  ];

  String? selectedSyringe;
  String? selectedNeedle;
  String? selectedFilm;
  String? selectedPaper;

  String radioValue = "Ya";
  TextEditingController catatanController = TextEditingController();

  Map<String, Map<String, String>> selectedData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part C. Penerimaan dan Inspeksi Material/Komponen"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Sticky Header Outside Scroll View
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 250,
                  child: Image.asset('assets/logos/logo_oneject.png', height: 50),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("BATCH RECORD",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildAlignedText("P/C Code", widget.task.code),
                      _buildAlignedText("P/C Name", widget.task.name),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Material/Component Name"),
                  _buildMaterialSection("Disposable Syringe", (val) {
                    setState(() => selectedSyringe = val);
                  }, selectedSyringe),
                  const SizedBox(height: 10),

                  _sectionTitle("Material/Component Name"),
                  _buildMaterialSection("Bulk Needle", (val) {
                    setState(() => selectedNeedle = val);
                  }, selectedNeedle),
                  const SizedBox(height: 10),

                  _sectionTitle("Material/Component Name"),
                  _buildMaterialSection("Sterile Film (Blister)", (val) {
                    setState(() => selectedFilm = val);
                  }, selectedFilm),
                  const SizedBox(height: 10),

                  _sectionTitle("Material/Component Name"),
                  _buildMaterialSection("Sterile Paper", (val) {
                    setState(() => selectedPaper = val);
                  }, selectedPaper),
                  const SizedBox(height: 10),

                  const Divider(thickness: 1),
                  const SizedBox(height: 24),
                  _buildCriteriaTable(),
                  const SizedBox(height: 24),
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
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
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

  Widget _buildMaterialSection(String title, Function(String?) onChanged, String? selectedValue) {
    final selected = materials.firstWhere(
            (element) => element["name"] == selectedValue,
        orElse: () => {"code": "", "uom": "", "reqQty": ""});

    final actualQtyController = TextEditingController();
    final batchNoController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold,)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: materials
              .map((material) => DropdownMenuItem<String>(
            value: material["name"],
            child: Text(material["name"] ?? ""),
          ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDetailField("Component/Material Code", selected["code"] ?? "", true, fillColor: Colors.lightBlue[50]),
            _buildDetailField("UoM", selected["uom"] ?? "", true, fillColor: Colors.lightBlue[50]),
            _buildDetailField("Required Quantity", selected["reqQty"] ?? "", true, fillColor: Colors.lightBlue[50]),
            _buildDetailField("Actual Quantity", "", false, controller: actualQtyController),
            _buildDetailField("Batch Number", "", false, controller: batchNoController),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailField(
      String label,
      String value,
      bool readOnly, {
        TextEditingController? controller,
        Color? fillColor, // <-- add this
      }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: controller ?? TextEditingController(text: value),
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: fillColor != null, // <-- only filled if color is provided
            fillColor: fillColor, // <-- use the passed fillColor
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> criteriaList = [
    {
      "id": "1",
      "text": "Material/komponen yang diterima sesuai dengan Production Picking List",
      "translation": "Received materials/components match the Production Picking List"
    },
    {
      "id": "2",
      "text": "Nomor bets/lot/serial number material/komponen sesuai dengan Production Picking List",
      "translation": "Material/component batch/lot/serial number matches the Production Picking List"
    },
    {
      "id": "3",
      "text": "Material/komponen lengkap untuk proses produksi",
      "translation": "Material/components are complete for the production process"
    },
  ];

  Map<String, String> radioSelections = {};
  Map<String, TextEditingController> catatanControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and radio values
    for (var item in criteriaList) {
      catatanControllers[item["id"]!] = TextEditingController();
      radioSelections[item["id"]!] = ""; // Initialize with empty
    }
  }

  Widget _buildCriteriaTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: criteriaList.map((item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Criteria
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["text"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item["translation"]!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Right side: Radio "Ya"/"Tidak"
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: "Ya",
                              groupValue: radioSelections[item["id"]],
                              onChanged: (value) {
                                setState(() {
                                  radioSelections[item["id"]!] = value!;
                                });
                              },
                            ),
                            const Text("Ya"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "Tidak",
                              groupValue: radioSelections[item["id"]],
                              onChanged: (value) {
                                setState(() {
                                  radioSelections[item["id"]!] = value!;
                                });
                              },
                            ),
                            const Text("Tidak"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Catatan Section below each criterion
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: catatanControllers[item["id"]],
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Catatan",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

}
