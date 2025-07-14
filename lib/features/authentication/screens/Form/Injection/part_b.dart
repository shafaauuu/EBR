import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/size.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class PartB_Injection extends StatefulWidget {
  final Task task;
  const PartB_Injection({super.key, required this.task});

  @override
  _PartB_InjectionState createState() => _PartB_InjectionState();
}

class _PartB_InjectionState extends State<PartB_Injection> {
  late final TaskDetailsController controller;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskDetailsController());
    check();
  }
  void check() async {
    await controller.fetchMachinesByBRM(widget.task.brmNo);
    await controller.fetchFormBInjectionData(widget.task.id.toString());
    setState(() {
      counter++;
    }); // trigger a rebuild


  }

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

                    const SizedBox(width: 16), // Small spacing between columns

                    // Third column: BRM, Rev No, Eff. Date
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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

              const SizedBox(height: Sizes.spaceBtwItems),
              const Text(
                "Mesin/Perlengkapan",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Machine/Tools",
                style: TextStyle(
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
                  onPressed: () async {
                    final controller = Get.put(TaskDetailsController());

                    List<Map<String, dynamic>> payload = [];

                    for (var machine in controller.machines) {
                      final machineCode = machine['machine_code'];
                      final selected = controller.selectedValues[machineCode];

                      if (selected != null) {
                        payload.add({
                          "task_id": widget.task.id,
                          "code_task": widget.task.code,
                          "machine_id": machineCode,
                          "terkualifikasi": selected == "Terkualifikasi",
                        });
                      }
                    }

                    if (payload.isEmpty) {
                      ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.warning,
                          title: "Warning",
                          text: "Please select qualification for at least one machine before submitting.",
                        ),
                      );
                      return;
                    }

                    try {
                      final response = await controller.submitQualificationDataInjection(payload);
                      if (response) {
                        ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.success,
                            title: "Success",
                            text: "Data submitted successfully!",
                          ),
                        );
                      } else {
                        ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error",
                            text: "Failed to submit data.",
                          ),
                        );
                      }
                    } catch (e) {
                      ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.danger,
                          title: "Exception",
                          text: "Something went wrong: $e",
                        ),
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
    return Obx(() {
      if (controller.machines.isEmpty) {
        return const Text("No machines found for selected BRM.");
      }

      List<TableRow> rows = [];

      for (int i = 0; i < controller.machines.length; i += 2) {
        List<Widget> rowChildren = [];

        for (int j = i; j < i + 2 && j < controller.machines.length; j++) {
          final machine = controller.machines[j];
          final machineName = machine['machine_name'] ?? 'Unknown';
          final machineCode = machine['machine_code'] ?? 'Unknown';

          rowChildren.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machineName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildRadioOptions(machineCode),
                ],
              ),
            ),
          );
        }

        while (rowChildren.length < 2) {
          rowChildren.add(Container());
        }

        rows.add(TableRow(children: rowChildren));
      }

      return Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
        },
        children: rows,
      );
    });
  }

  Widget _buildRadioOptions(String machineId) {
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Row(
          children: [
            _buildSingleRadioOption(machineId, "Terkualifikasi", "Qualified"),
            _buildSingleRadioOption(machineId, "Tidak Terkualifikasi", "Unqualified"),
            _buildSingleRadioOption(machineId, "N/A", "Not Applicable"),
          ],
        );
      },
    );
  }

  Widget _buildSingleRadioOption(String machineId, String value, String translation) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String?>(
          value: value,
          groupValue: controller.selectedValues[machineId],
          onChanged: (selected) {
            setState(() {
              controller.selectedValues[machineId] = selected;
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
