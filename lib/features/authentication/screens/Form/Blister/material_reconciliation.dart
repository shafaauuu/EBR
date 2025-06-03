import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';

class MaterialReconciliationBlister extends StatefulWidget {
  final VoidCallback onSubmit;
  final Task task;
  final List<String> plungerDropdownItems;
  final String? selectedPlungerItem;
  final void Function(String?) onPlungerChanged;
  final List<TextEditingController> plungerControllers;

  final List<String> barrelDropdownItems;
  final String? selectedBarrelItem;
  final void Function(String?) onBarrelChanged;
  final List<TextEditingController> barrelControllers;

  final List<String> needleDropdownItems;
  final String? selectedNeedleItem;
  final void Function(String?) onNeedleChanged;
  final List<TextEditingController> needleControllers;

  const MaterialReconciliationBlister({
    Key? key,
    required this.onSubmit,
    required this.task,
    required this.plungerDropdownItems,
    required this.selectedPlungerItem,
    required this.onPlungerChanged,
    required this.plungerControllers,
    required this.barrelDropdownItems,
    required this.selectedBarrelItem,
    required this.onBarrelChanged,
    required this.barrelControllers,
    required this.needleDropdownItems,
    required this.selectedNeedleItem,
    required this.onNeedleChanged,
    required this.needleControllers,
  }) : super(key: key);

  @override
  State<MaterialReconciliationBlister> createState() => _MaterialReconciliationBlisterState();
}

class _MaterialReconciliationBlisterState extends State<MaterialReconciliationBlister> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  Widget _buildAlignedText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text("$label :", style: const TextStyle(fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedItem,
          items: dropdownItems
              .map((String value) =>
              DropdownMenuItem<String>(value: value, child: Text(value)))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select Here',
          ),
        ),
        const SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Material Reconciliation",
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 250,
                  child: Image.asset('assets/logos/logo_oneject.png',
                      height: 50),
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
                      Obx(() => _buildAlignedText(
                          "BRM No.", controller.selectedBRM.value)),
                      _buildAlignedText("Rev No.", ""),
                      _buildAlignedText("Eff. Date", ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildMaterialRow("Plunger", widget.plungerDropdownItems,
                      widget.selectedPlungerItem, widget.onPlungerChanged, widget.plungerControllers),
                  const Divider(height: 32),
                  buildMaterialRow("Barrel", widget.barrelDropdownItems,
                      widget.selectedBarrelItem, widget.onBarrelChanged, widget.barrelControllers),
                  const Divider(height: 32),
                  buildMaterialRow("Needle", widget.needleDropdownItems,
                      widget.selectedNeedleItem, widget.onNeedleChanged, widget.needleControllers),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: widget.onSubmit,
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
}
