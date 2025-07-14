import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import '../../../controller/Form/D/material_recon_controller.dart';
import '../../../models/task_model.dart';
import '../../../controller/task_details_controller.dart';

class MaterialReconciliationAssySyringe extends StatefulWidget {
  final Task task;
  final String selectedMaterialCode;

  const MaterialReconciliationAssySyringe({
    Key? key,
    required this.task,
    required this.selectedMaterialCode,
  }) : super(key: key);

  @override
  State<MaterialReconciliationAssySyringe> createState() => _MaterialReconciliationAssySyringeState();
}

class _MaterialReconciliationAssySyringeState extends State<MaterialReconciliationAssySyringe> {
  late MaterialReconController controller;
  final TaskDetailsController taskDetailsController = Get.find<TaskDetailsController>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(MaterialReconController(
      widget.task, 
      widget.selectedMaterialCode
    ));
    
    // Check if material code is selected
    if (widget.selectedMaterialCode.isEmpty) {
      // Show alert and navigate back after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.warning,
            title: "Warning",
            text: "Please choose the material first",
            confirmButtonText: "OK",
            onConfirm: () {
              Navigator.of(context).pop(); // Close the alert
              Get.back(); // Return to task_details
            }
          )
        );
      });
    } else {
      // Fetch child materials when the screen loads and material is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchChildMaterials();
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    controller.dispose();
    super.dispose();
  }

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

  Widget _buildMaterialRow(Map<String, dynamic> material) {
    final materialId = material['id_bom']?.toString() ?? '';
    if (materialId.isEmpty) return const SizedBox.shrink();
    
    final childMaterial = material['child_material'] ?? material['childMaterial'];
    if (childMaterial == null) return const SizedBox.shrink();
    
    final materialDesc = childMaterial['material_desc'] ?? childMaterial['material_name'] ?? 'Unknown Material';
    final materialCode = childMaterial['material_code'] ?? '';
    final materialUom = childMaterial['material_uom'] ?? '';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(materialDesc, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue,)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text("Code: $materialCode", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                Text("UOM: $materialUom", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var label in [
                  'Jumlah\nAwal',
                  'Jumlah\nTambahan',
                  'Jumlah\nReject',
                  'Jumlah\nTerpakai',
                  'Jumlah\nKarantina',
                  'Sisa\nProduksi',
                  'Jumlah\nMusnah',
                  'Jumlah\nKembali',
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlAwalControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        // Auto-calculate sisa based on input values
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlSpbtControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlRejectControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlPakaiControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlKarantinaControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.sisaControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.lightBlue.shade50,
                        labelText: 'Auto',
                        labelStyle: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                      ),
                      readOnly: true, // Make this field read-only as it's calculated
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlMusnahControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: controller.jmlKembaliControllers[materialId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _calculateSisa(materialId);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate sisa (remaining) value
  void _calculateSisa(String materialId) {
    try {
      // Get values from controllers
      final jmlAwal = int.tryParse(controller.jmlAwalControllers[materialId]?.text ?? '') ?? 0;
      final jmlSpbt = int.tryParse(controller.jmlSpbtControllers[materialId]?.text ?? '') ?? 0;
      final jmlReject = int.tryParse(controller.jmlRejectControllers[materialId]?.text ?? '') ?? 0;
      final jmlPakai = int.tryParse(controller.jmlPakaiControllers[materialId]?.text ?? '') ?? 0;
      final jmlKarantina = int.tryParse(controller.jmlKarantinaControllers[materialId]?.text ?? '') ?? 0;
      final jmlMusnah = int.tryParse(controller.jmlMusnahControllers[materialId]?.text ?? '') ?? 0;
      final jmlKembali = int.tryParse(controller.jmlKembaliControllers[materialId]?.text ?? '') ?? 0;
      
      // Calculate sisa: jmlAwal + jmlSpbt - jmlReject - jmlPakai - jmlKarantina - jmlMusnah - jmlKembali
      final sisa = jmlAwal + jmlSpbt - jmlReject - jmlPakai - jmlKarantina - jmlMusnah - jmlKembali;
      
      // Update sisa controller
      controller.sisaControllers[materialId]?.text = sisa.toString();
    } catch (e) {
      print('Error calculating sisa: $e');
    }
  }

  List<Widget> _buildDynamicMaterialSections() {
    List<Widget> sections = [];
    
    // Add each material as a section
    for (var material in controller.materials) {
      sections.add(
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: _buildMaterialRow(material),
        ),
      );
    }
    
    if (sections.isEmpty) {
      sections.add(
        const Center(
          child: Text(
            "No materials found for reconciliation",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return sections;
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
                      _buildAlignedText("BRM No.", taskDetailsController.selectedBRM.value),
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Material Reconciliation Instructions:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "1. Enter the initial quantity in 'Jumlah Awal'",
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            "2. Fill in additional quantities and usage as needed",
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            "3. 'Sisa Produksi' will be calculated automatically",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Selected Material Code: ${widget.selectedMaterialCode}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dynamic material sections
                    ..._buildDynamicMaterialSections(),
                    const SizedBox(height: 24),
                    
                    Center(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                // Show confirmation dialog
                                final result = await ArtSweetAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.question,
                                    title: "Confirm Submission",
                                    text: "Are you sure you want to submit the material reconciliation data?",
                                    confirmButtonText: "Yes, Submit",
                                    cancelButtonText: "Cancel",
                                    showCancelBtn: true,
                                  ),
                                );
                                
                                // If confirmed, submit the form
                                if (result != null && result.isTapConfirmButton) {
                                  final success = await controller.submitForm();
                                  if (success) {
                                    // Navigate back after successful submission
                                    Future.delayed(const Duration(seconds: 1), () {
                                      Get.back();
                                    });
                                  }
                                }
                              },
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
              );
            }),
          ),
        ],
      ),
    );
  }
}
