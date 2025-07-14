import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/Form/A/form_a_needle_assy_controller.dart';
import '../../../models/task_model.dart';
import '../../../controller/task_details_controller.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class PartA_NeedleAssy extends StatefulWidget {
  final Task task;
  const PartA_NeedleAssy({super.key, required this.task});

  @override
  _PartA_NeedleAssyState createState() => _PartA_NeedleAssyState();
}

class _PartA_NeedleAssyState extends State<PartA_NeedleAssy> {
  final FormANeedleassyController needleassyController = Get.put(FormANeedleassyController());
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  DateTime? _selectedDate;
  TextEditingController dateController = TextEditingController();

  final Map<String, TextEditingController> numericResponses = {
    "temperature": TextEditingController(),
    "humidity": TextEditingController(),
  };
  int counter = 0;

  final TextEditingController batchController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController previousProductController = TextEditingController();
  final TextEditingController needleController = TextEditingController();
  final TextEditingController capController = TextEditingController();

  @override
  void initState() {
    super.initState();
    check();
  }
  void check() async {
    final controller = Get.put(FormANeedleassyController());
    await controller.fetchFormANeedleAssy(widget.task.id.toString());
    setState(() {
      counter++;
    }); // triggers rebuild


  }

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
          // Sticky Header Section
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
                      _buildAlignedText("P/C Code", widget.task.code),
                      _buildAlignedText("P/C Name", widget.task.name),
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
                      _buildAlignedText("BRM No.", widget.task.brmNo),
                      _buildAlignedText("Rev No.", ""),
                      _buildAlignedText("Eff. Date", ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          // Main Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information Table
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Row: "Tanggal/Date" (No Table)
                        const Text(
                          "Tanggal / Date",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                "Tanggal",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => _pickDate(context),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: needleassyController.dateController,
                                    decoration: InputDecoration(
                                      hintText: "DD/MM/YYYY",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSectionHeader(
                            "Produk yang sebelumnya diproses pada line ini",
                          "Previous product name processed inn this production line"
                        ),

                        // Second Table: Nama Produk & Nomor Bets
                        Table(
                          border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(5),
                            1: FlexColumnWidth(5),
                          },
                          children: [
                            // Row 1: Nama Produk/Komponen
                            TableRow(
                              children: [
                                _buildTableCell("Nama Produk/Komponen", "Product/Component Name"),
                                _buildTextFieldCell(needleassyController.productNameController), // Input field
                              ],
                            ),
                            // Row 2: Nomor Bets
                            TableRow(
                              children: [
                                _buildTableCell("Nomor Bets", "Batch No."),
                                _buildTextFieldCell(needleassyController.batchController), // Input field
                              ],
                            ),
                            // Row 3: Jenis Needle
                            TableRow(
                              children: [
                                _buildTableCell("Jenis Needle", "Needle Type"),
                                _buildTextFieldCell(needleassyController.needleController), // Input field
                              ],
                            ),
                            // Row 4: Jenis Cap
                            TableRow(
                              children: [
                                _buildTableCell("Jenis Cap", "Cap Type"),
                                _buildTextFieldCell(needleassyController.capController), // Input field
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSectionHeader(
                        "Kebersihan Line Produksi meliputi:",
                        "Cleanliness of the production line includes:"
                    ),

                    // Table Section
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        _buildQuestionRow("a. Palet untuk menaruh komponen dalam keadaan bersih", "Pallets for placing components are clean", "pallet_clean"),
                        _buildQuestionRow("b. Lantai bersih (tidak lengket dan tidak ada genangan air)", "Floor is clean (not sticky and dry)", "floor_clean"),
                        _buildQuestionRow("c. Kolong mesin dalam keadaan bersih dan kosong (tidak ada benda asing)", "Area under machine is clean and empty (no foreign objects)", "under_machine_clean"),
                        _buildQuestionRow("d. Area atas mesin dalam keadaan bersih dan kosong (tidak ada benda asing)", "Area above machine is clean and empty (no foreign object)", "above_machine_clean"),
                        _buildQuestionRow("e. Return grill dalam keadaan bersih", "Return grills are clean", "grill_clean"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSectionHeader(
                        "Tidak ada sisa produk/komponen/material sebelumnya:",
                        "There is no previous product/component/material"
                    ),

                    // Table Section
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        _buildYesNoRow("a. Tidak ada sisa produk atau komponen yang berceceran di lantai atau palet", "There is no previous product or component scattered on floor or pallet", "no_product_left"),
                        _buildYesNoRow("b. Tidak ada sisa Hub pada area hopper bawah, hopper atas, conveyor hopper, dan sepanjang rel", "There is no previous barrel in bottom hopper, top hopper, hopper conveyor, and along the rail", "no_hub_left"),
                        _buildYesNoRow("c. Tidak ada sisa Cap pada area hopper bawah, hopper atas, conveyor hopper, dan sepanjang rel", "There is no previous plunger in bottom hopper, top hopper, hopper conveyor, and along the rail", "no_cap_left"),
                        _buildYesNoRow("d. Tidak ada sisa Cannula  pada area hopper dan sepanjang rel", "There is no previous bulk needle on hopper area and along the rail", "no_cannula_left"),
                        _buildYesNoRow("e. Tidak ada sisa produk pada box hasil", "There is no previous product in output box", "no_output_left"),
                        _buildYesNoRow("f. Tidak ada sisa produk reject pada box reject", "There is no previous reject product in reject box", "no_reject_left"),
                        _buildYesNoRow("g. Tidak ada sisa komponen rework pada wadah rework", "There is no previous rework component in rework container", "no_rework_left"),

                        _buildYesNoRow("Tidak ada dokumen, catatan, atau label dari proses produksi sebelumnya", "There is no documents, records, or label from previous production process", "no_docs_left"),
                        _buildYesNoRow("Material sesuai dengan Picking List dan CoA komponen (Tanggal Kadaluarsa, Tanggal Produksi dan Nama Material", "Material According to the picking list and components of the CoA (Expire Date, Manufacturing Date and Material Name)", "picking_list"),
                        _buildYesNoRow("Dokumen yang terkait proses produksi batch berjalan, telah berada di area mesin, meliputi Picklist, Label Status Mesin & Ruangan, dan Label Identitas Running", "Documents related to production process of on going batch, have been placed in machine area, include Picklist, Status Label of Machine & Room, and idenity Running Label", "document_related"),

                        _buildNumberInputRow("Pernyataan Suhu Lingkungan (T)", "Environmental Temperature (20-26°C)", "temperature"),
                        _buildNumberInputRow("Pernyataan Kelembapan Relatif (RH)", "Relative Humidity (<70%)", "humidity"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (validateForm()) {
                            final controller = Get.put(FormANeedleassyController());
                            controller.submitForm(                              context: context,
                              task_id: widget.task.id,
                              codeTask: widget.task.code,
                              tanggal: DateTime.parse(needleassyController.dateController.text.replaceAll('/', '-')).toIso8601String().substring(0, 10),
                              sebelumProduk: needleassyController.productNameController.text,
                              sebelumBets: needleassyController.batchController.text,
                              sebelumNeedle: needleassyController.needleController.text,
                              sebelumCap: needleassyController.capController.text,
                              responses: needleassyController.responses,
                              numericResponses: needleassyController.numericResponses,
                            );
                          }
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label, String translation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue, // Blue color for original text
            ),
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

  TableRow _buildQuestionRow(String left, String right, String key) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(left),
            Text(
              right,
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align options horizontally
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: needleassyController.responses[key],
                  onChanged: (value) {
                    setState(() => needleassyController.responses[key] = value);
                  },
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bersih"),
                    Text(
                      "Clean",
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20), // Spacing between options
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: needleassyController.responses[key],
                  onChanged: (value) {
                    setState(() => needleassyController.responses[key] = value);
                  },
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tidak Bersih"),
                    Text(
                      "Not Clean",
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  TableRow _buildYesNoRow(String left, String right, String key) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(left),
            Text(
              right,
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align options horizontally
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: needleassyController.responses[key],
                  onChanged: (value) {
                    setState(() => needleassyController.responses[key] = value);
                  },
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ya"),
                    Text(
                      "Yes",
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20), // Spacing between options
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: needleassyController.responses[key],
                  onChanged: (value) {
                    setState(() => needleassyController.responses[key] = value);
                  },
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tidak"),
                    Text(
                      "No",
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  TableRow _buildNumberInputRow(String left, String right, String key) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(left),
            Text(
              right,
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: needleassyController.numericResponses[key],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: right),
        ),
      ),
    ]);
  }

  Widget _buildTableCell(String label, String translation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(translation, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTextFieldCell(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        needleassyController.dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  bool validateForm() {
    // Validate text inputs
    if (needleassyController.dateController.text.isEmpty ||
        needleassyController.productNameController.text.isEmpty ||
        needleassyController.batchController.text.isEmpty ||
        needleassyController.needleController.text.isEmpty ||
        needleassyController.capController.text.isEmpty ||
        needleassyController.numericResponses['temperature']?.text.isEmpty == true ||
        needleassyController.numericResponses['humidity']?.text.isEmpty == true) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Missing Fields",
          text: "Please fill all required fields.",
        ),
      );
      return false;
    }

    // Validate radio/boolean responses
    for (var entry in needleassyController.responses.entries) {
      if (entry.value == null) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Incomplete Selections",
            text: "Please complete all Yes/No/Clean selections.",
          ),
        );
        return false;
      }
    }

    return true;
  }

}
