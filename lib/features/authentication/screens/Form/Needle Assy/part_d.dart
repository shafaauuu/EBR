import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class PartD extends StatefulWidget {
  final Task task;
  const PartD({super.key, required this.task});

  @override
  _PartDState createState() => _PartDState();
}

class _PartDState extends State<PartD> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedMachine;
  DateTime? _selectedDateTime;
  String? _lineClearance; // 'YA' or 'TIDAK'

  final List<String> machineList = ['Mesin A', 'Mesin B', 'Mesin C', 'Mesin D'];

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
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mesin yang digunakan (Dropdown)
                  const Text("Mesin yang Digunakan:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 20),

                  // Line Clearance (Inline Radio Buttons)
                  const Text(
                    "Line Clearance dilakukan?",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 20),

                  // Instruction Text
                  const Text("Instruksi Kerja:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      hintText: "Masukkan instruksi kerja...",
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitPartD,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Submit",
                          style: TextStyle(fontSize: 16)),
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

  void _submitPartD() {
    // You can process and save the data here
    Get.snackbar("Success", "Data Part D berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }
}
