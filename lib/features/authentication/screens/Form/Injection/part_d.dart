import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oji_1/features/authentication/screens/Form/Injection/material_reconciliation.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class PartD_Injection extends StatefulWidget {
  final Task task;
  const PartD_Injection({super.key, required this.task});

  @override
  _PartD_InjectionState createState() => _PartD_InjectionState();
}

class _PartD_InjectionState extends State<PartD_Injection> {
  Uint8List? _webImage;

  final TaskDetailsController controller = Get.put(TaskDetailsController());

  List<TextEditingController> printingActualControllers = List.generate(3, (_) => TextEditingController());
  List<bool> printingStatusChecks = List.generate(3, (_) => false);

  List<TextEditingController> assyActualControllers = List.generate(2, (_) => TextEditingController());
  List<bool> assyStatusChecks = List.generate(2, (_) => false);


  List<bool> _siapRunningChecks = [false, false, false]; // for Barrel, Plunger, Gasket

  String? _selectedMachine;
  DateTime? _selectedDateTime;
  String? _lineClearance; // 'YA' or 'TIDAK'

  final List<String> machineList = ['Mesin A', 'Mesin B', 'Mesin C', 'Mesin D'];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Dropdown data and states
  List<String> plungerDropdownItems = ['Item A', 'Item B'];
  String? selectedPlungerItem;
  void onPlungerChanged(String? val) => setState(() => selectedPlungerItem = val);

  List<String> barrelDropdownItems = ['Item C', 'Item D'];
  String? selectedBarrelItem;
  void onBarrelChanged(String? val) => setState(() => selectedBarrelItem = val);

  List<String> needleDropdownItems = ['Item E', 'Item F'];
  String? selectedNeedleItem;
  void onNeedleChanged(String? val) => setState(() => selectedNeedleItem = val);

  // Controllers for each field (5 fields per item)
  List<TextEditingController> plungerControllers = List.generate(8, (_) => TextEditingController());
  List<TextEditingController> barrelControllers = List.generate(8, (_) => TextEditingController());
  List<TextEditingController> needleControllers = List.generate(8, (_) => TextEditingController());


  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Select Image Source',
      desc: 'Choose where to get the image from:',
      btnOkText: "Camera",
      btnOkColor: Colors.blue, // Blue for Camera
      btnOkOnPress: () {
        _pickImage(ImageSource.camera);
      },
      btnCancelText: "Gallery",
      btnCancelColor: Colors.blue, // Green for Gallery
      btnCancelOnPress: () {
        _pickImage(ImageSource.gallery);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part D. Instruksi Kerja dan Catatan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Sticky Header
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

          // Scrollable Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waktu & Tanggal Mulai
                  const Text("Waktu & Tanggal Mulai:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedDateTime != null
                            ? "${_selectedDateTime!.toLocal()}".split('.')[0]
                            : "Pilih tanggal dan waktu",
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Mesin yang digunakan (Dropdown)
                  const Text("Mesin yang Digunakan:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedMachine,
                    items: machineList.map((machine) {
                      return DropdownMenuItem(
                        value: machine,
                        child: Text(machine),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMachine = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                    hint: const Text("Pilih Mesin"),
                  ),
                  const SizedBox(height: 30),

                  // Line Clearance (Inline Radio Buttons)
                  const Text(
                    "Line Clearance dilakukan?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Pilih: "),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Sudah',
                            groupValue: _lineClearance,
                            onChanged: (value) {
                              setState(() {
                                _lineClearance = value;
                              });
                            },
                          ),
                          const Text('Sudah'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Tidak',
                            groupValue: _lineClearance,
                            onChanged: (value) {
                              setState(() {
                                _lineClearance = value;
                              });
                            },
                          ),
                          const Text('Tidak'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  buildCustomTableSection(),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Take Photo of Machine",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Photo Insert Field (Updated)
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(context),
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _image == null
                          ? const Center(
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      )
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Divider(thickness: 1),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaterialReconciliationInjection(
                              onSubmit: _submitPartD,
                              task: widget.task,
                              plungerDropdownItems: plungerDropdownItems,
                              selectedPlungerItem: selectedPlungerItem,
                              onPlungerChanged: onPlungerChanged,
                              plungerControllers: plungerControllers,
                              barrelDropdownItems: barrelDropdownItems,
                              selectedBarrelItem: selectedBarrelItem,
                              onBarrelChanged: onBarrelChanged,
                              barrelControllers: barrelControllers,
                              needleDropdownItems: needleDropdownItems,
                              selectedNeedleItem: selectedNeedleItem,
                              onNeedleChanged: onNeedleChanged,
                              needleControllers: needleControllers,
                            ),
                          ),
                        );
                      },
                      child: const Text("Next",
                          style: TextStyle(fontSize: 16)
                      ),
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

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Widget buildCustomTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // optional, Center() below handles it
      children: [
        sectionTitle("Printing Parameter"),
        const SizedBox(height: 8),
        buildTable(
          [
            ["Parameter", "Actual", "Status"],
            ["Speed rotary inside", "3 - 5", "3 - 5"],
            ["Speed rotary outside", "4 - 7", "4 - 7"],
            ["Machine speed", "2 - 4", "2 - 4"],
          ],
          printingActualControllers,
          printingStatusChecks,
              (index, value) {
            setState(() {
              printingStatusChecks[index] = value!;
            });
          },
        ),

        const SizedBox(height: 20),
        sectionTitle("Assy Parameter"),
        const SizedBox(height: 8),
        buildTable(
          [
            ["Parameter", "Actual", "Status"],
            ["Machine speed (mm/min)", "2000 - 3000", "2000 - 3000"],
            ["Air Pressure (Bar)", "4 - 6", "4 - 6"],
          ],
          assyActualControllers,
          assyStatusChecks,
              (index, value) {
            setState(() {
              assyStatusChecks[index] = value!;
            });
          },
        ),

        const SizedBox(height: 20),
        sectionTitle("Loading pada buffer"),
        const SizedBox(height: 8),
        buildChecklistTable([
          ["Barrel"],
          ["Plunger"],
          ["Gasket"],
        ]),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Center(
      child: Container(
        width: 500, // should match the table width
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildTable(
      List<List<String>> rows,
      List<TextEditingController> controllers,
      List<bool> statusChecks,
      void Function(int index, bool? value) onStatusChanged,
      ) {
    return Center(
      child: Container(
        width: 500, // Adjust as needed
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.5),
          },
          children: List<TableRow>.generate(rows.length, (index) {
            final row = rows[index];

            return TableRow(
              decoration: index == 0
                  ? const BoxDecoration(color: Color(0xFFEFEFEF))
                  : null,
              children: List<Widget>.generate(row.length, (colIndex) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row[colIndex],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (colIndex == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(row[colIndex]),
                  );
                } else if (colIndex == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: TextFormField(
                      controller: controllers[index - 1],
                      decoration: InputDecoration(
                        hintText: row[colIndex],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  );
                } else {
                  bool isChecked = statusChecks[index - 1];
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            onStatusChanged(index - 1, value);
                          },
                        ),
                        const Text("OK"),
                      ],
                    ),
                  );
                }
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget buildChecklistTable(List<List<String>> items) {
    return Center(
      child: Container(
        width: 500, // Match or customize as needed
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Loading pada buffer", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Siap Running", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...items.asMap().entries.map((entry) {
              int i = entry.key;
              List<String> row = entry.value;

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(row[0]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _siapRunningChecks[i],
                          onChanged: (bool? value) {
                            setState(() {
                              _siapRunningChecks[i] = value ?? false;
                            });
                          },
                        ),
                        const Text("Ya"),
                        const SizedBox(width: 10),
                        const Text("/"),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: !_siapRunningChecks[i],
                          onChanged: (bool? value) {
                            setState(() {
                              _siapRunningChecks[i] = !(value ?? false);
                            });
                          },
                        ),
                        const Text("Tidak"),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildMaterialRow(
      String title,
      List<String> dropdownItems,
      String? selectedItem,
      ValueChanged<String?> onChanged,
      List<TextEditingController> controllers,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedItem,
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select Here',
          ),
        ),
        const SizedBox(height: 8),

        // Row for labels
        Row(
          children: [
            for (var label in [
              'Jumlah Awal',
              'Jumlah Tambahan (SPBT)',
              'Jumlah Reject',
              'Jumlah Terpakai',
              'Jumlah Material Karantina',
              'Sisa Setelah Produksi',
              'Jumlah Dimusnahkan',
              'Jumlah Dikembalikan',
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Row for input fields
        Row(
          children: [
            for (var i = 0; i < controllers.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: controllers[i],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPartD() {
    // You can process and save the data here
    Get.snackbar("Success", "Data Part D berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }
}
