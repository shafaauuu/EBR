import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import '../../../controller/Form/C/form_c_blister.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:intl/intl.dart';

class PartC_Blister extends StatefulWidget {
  final Task task;
  const PartC_Blister({super.key, required this.task});

  @override
  _PartC_BlisterState createState() => _PartC_BlisterState();
}

class _PartC_BlisterState extends State<PartC_Blister> {
  late final FormCBlisterController controller;

  // Form values
  final Map<String, dynamic> formValues = {
    'sesuai_picklist': true,
    'remarks_picklist': '',
    'sesuai_bets': true,
    'remarks_bets': '',
    'mat_lengkap': true,
    'remarks_mat': '',
  };

  // Store selected materials by material ID
  final Map<String, Map<String, dynamic>> selectedMaterials = {};

  @override
  void initState() {
    super.initState();
    controller = Get.put(FormCBlisterController(widget.task));

    for (var item in criteriaList) {
      catatanControllers[item["id"]!] = TextEditingController();
      radioSelections[item["id"]!] = "";
    }

    // Initialize material controllers when materials are loaded
    ever(controller.materials, (materials) {
      for (var material in materials) {
        final id = material['id']?.toString() ?? '';
        if (id.isNotEmpty && !batchControllers.containsKey(id)) {
          batchControllers[id] = TextEditingController();
          qtyControllers[id] = TextEditingController();
        }
      }
    });

    // Listen for existing data and update UI accordingly
    ever(controller.existingFormData, (data) {
      if (data != null) {
        setState(() {
          // Update radio selections
          radioSelections['1'] = data['sesuai_picklist'] == true ? 'Ya' : 'Tidak';
          radioSelections['2'] = data['sesuai_bets'] == true ? 'Ya' : 'Tidak';
          radioSelections['3'] = data['mat_lengkap'] == true ? 'Ya' : 'Tidak';

          // Update catatan controllers
          catatanControllers['1']?.text = data['remarks_picklist'] ?? '';
          catatanControllers['2']?.text = data['remarks_bets'] ?? '';
          catatanControllers['3']?.text = data['remarks_mat'] ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building PartC_Blister widget");
    print("Controller loading state: ${controller.isLoading.value}");
    print("Materials count: ${controller.materials.length}");

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
                      _buildAlignedText("BRM No.", widget.task.brmNo ?? ''),
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
            child: Obx(() {
              print("Rebuilding with loading: ${controller.isLoading.value}, materials: ${controller.materials.length}");
              
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading materials...")
                    ],
                  )
                );
              }
              
              if (controller.materials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        "No materials found",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please check your API endpoint or network connection",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        onPressed: () {
                          controller.isLoading.value = true;
                          controller.fetchChildMaterials().then((_) {
                            controller.isLoading.value = false;
                          });
                        },
                      )
                    ],
                  ),
                );
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildDynamicMaterialSections(),
                    const SizedBox(height: 24),

                    const Divider(thickness: 1),
                    const SizedBox(height: 24),
                    _buildCriteriaTable(),
                    const SizedBox(height: 24),
                    Center(
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                            // Validate form
                            bool isValid = true;

                            // Validate radio buttons
                            for (var item in criteriaList) {
                              final id = item["id"]!;
                              if (radioSelections[id]?.isEmpty ?? true) {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "Perhatian",
                                        text: "Harap jawab semua kriteria"
                                    )
                                );
                                isValid = false;
                                break;
                              }

                              // Validate notes for "Tidak" answers
                              if (radioSelections[id] == "Tidak" &&
                                  (catatanControllers[id]?.text.isEmpty ?? true)) {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "Perhatian",
                                        text: "Harap isi catatan untuk kriteria yang dipilih \"Tidak\""
                                    )
                                );
                                isValid = false;
                                break;
                              }
                            }

                            if (!isValid) return;

                            // Validate at least one material is selected
                            if (selectedMaterials.isEmpty) {
                              ArtSweetAlert.show(
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.warning,
                                      title: "Perhatian",
                                      text: "Harap pilih minimal satu material"
                                  )
                              );
                              return;
                            }

                            // Validate batch numbers and quantities
                            bool hasValidationError = false;
                            for (var entry in selectedMaterials.entries) {
                              final materialId = entry.key;
                              final batchNo = batchControllers[materialId]?.text ?? '';
                              final qtyStr = qtyControllers[materialId]?.text ?? '0';
                              final qty = int.tryParse(qtyStr) ?? 0;

                              if (batchNo.isEmpty) {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "Perhatian",
                                        text: "Harap isi nomor batch"
                                    )
                                );
                                hasValidationError = true;
                                break;
                              }

                              if (qty <= 0) {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "Perhatian",
                                        text: "Harap isi kuantitas yang valid"
                                    )
                                );
                                hasValidationError = true;
                                break;
                              }
                            }


                            if (hasValidationError) return;

                            // Show confirmation dialog using ArtSweetAlert
                            final ArtDialogResponse response = await ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.question,
                                    title: "Konfirmasi",
                                    text: "Apakah Anda yakin ingin mengirim data ini?",
                                    confirmButtonText: "Ya, Kirim",
                                    denyButtonText: "Batal"
                                )
                            );

                            final confirmed = response != null && response.isTapConfirmButton;

                            if (confirmed) {
                              // Prepare form data with the correct structure for the backend API
                              final formData = {
                                'sesuai_picklist': radioSelections['1'] == 'Ya',
                                'remarks_picklist': catatanControllers['1']?.text ?? '',
                                'sesuai_bets': radioSelections['2'] == 'Ya',
                                'remarks_bets': catatanControllers['2']?.text ?? '',
                                'mat_lengkap': radioSelections['3'] == 'Ya',
                                'remarks_mat': catatanControllers['3']?.text ?? '',
                              };

                              // Update the controller's selectedMaterials with the current selections
                              for (var materialId in selectedMaterials.keys) {
                                controller.selectedMaterials[materialId] = selectedMaterials[materialId]!;

                                // Make sure the controllers have the latest values
                                if (batchControllers.containsKey(materialId)) {
                                  controller.batchControllers[materialId] = batchControllers[materialId]!;
                                }

                                if (qtyControllers.containsKey(materialId)) {
                                  controller.qtyControllers[materialId] = qtyControllers[materialId]!;
                                }
                              }

                              // Submit the form
                              final success = await controller.submitForm(formData);
                              if (success) {
                                Get.back(result: true);
                              }
                            }
                          },
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Submit", style: TextStyle(fontSize: 16)),
                        )
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


  // Build dynamic material sections based on fetched materials
  List<Widget> _buildDynamicMaterialSections() {
    final List<Widget> sections = [];
    
    print("Building material sections with ${controller.materials.length} materials");
    
    if (controller.materials.isEmpty) {
      // Add a message if no materials are found
      sections.add(
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: const Text(
            "No materials found. Please check your API endpoint.",
            style: TextStyle(color: Colors.red),
          ),
        )
      );
      return sections;
    }

    // Group materials by their type or category if needed
    // For now, we'll show each material as a separate section
    for (var material in controller.materials) {
      final materialId = material['id']?.toString() ?? '';
      
      if (materialId.isEmpty) {
        print("Warning: Material without ID found: $material");
        continue;
      }
      
      print("Processing material: $materialId - ${material['material_desc']}");

      // Initialize controllers if they don't exist
      if (!batchControllers.containsKey(materialId)) {
        batchControllers[materialId] = TextEditingController();
        qtyControllers[materialId] = TextEditingController();
      }

      // Check if there's existing data for this material
      final existingMaterialData = controller.existingMaterials
          .where((m) => m['material']?['id'].toString() == materialId)
          .toList();

      // If we have existing data, pre-populate the fields
      if (existingMaterialData.isNotEmpty) {
        final latestData = existingMaterialData.first;
        batchControllers[materialId]?.text = latestData['batch_no'] ?? '';
        qtyControllers[materialId]?.text = latestData['actual_qty']?.toString() ?? '';

        // Add to selected materials
        if (!selectedMaterials.containsKey(materialId)) {
          selectedMaterials[materialId] = {
            'id': materialId,
            'material_desc': material['material_desc'],
            'material_code': material['material_code'],
            'batch_no': latestData['batch_no'] ?? '',
            'actual_qty': latestData['actual_qty']?.toString() ?? '',
            'id_mat': material['id_mat'],
          };
        }
      }

      sections.addAll([
        _sectionTitle("Material/Component Name"),
        _buildMaterialSection(
          material['material_desc'] ?? 'Unnamed Material',
          materialId,
          material,
          batchControllers[materialId]!,
          qtyControllers[materialId]!,
        ),
        const SizedBox(height: 10),
      ]);
    }

    return sections;
  }

  Widget _buildMaterialSection(
      String title,
      String materialId,
      Map<String, dynamic> material,
      TextEditingController batchNoController,
      TextEditingController actualQtyController,
      ) {
    // Check if this material is selected
    final isSelected = selectedMaterials.containsKey(materialId);

    // If selected, update the selectedMaterials map
    if (isSelected && !selectedMaterials.containsKey(materialId)) {
      selectedMaterials[materialId] = {
        'id': materialId,
        'material_desc': material['material_desc'],
        'material_code': material['material_code'],
        'batch_no': batchNoController.text,
        'actual_qty': actualQtyController.text,
        'id_mat': material['id_mat'], // Store id_mat for child material
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
        ),
        const SizedBox(height: 8),
        // Display material name directly since we're not using dropdown for selection
        TextFormField(
          initialValue: material['material_desc'] ?? 'No Name',
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDetailField(
                "Component/Material Code",
                material['material_code'] ?? '',
                true,
                fillColor: Colors.lightBlue[50]
            ),
            _buildDetailField(
                "UoM",
                material['material_uom'] ?? '',
                true,
                fillColor: Colors.lightBlue[50]
            ),
            _buildDetailField(
                "Required Qty",
                material['qty']?.toString() ?? '',
                true,
                fillColor: Colors.lightBlue[50]
            ),
            _buildDetailField(
                "Actual Qty",
                "",
                false,
                controller: actualQtyController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Update the form values and selected materials
                  formValues['${materialId}_actual_qty'] = int.tryParse(value) ?? 0;

                  // Update or create the selected material entry
                  if (!selectedMaterials.containsKey(materialId)) {
                    selectedMaterials[materialId] = {
                      'id': materialId,
                      'material_desc': material['material_desc'],
                      'material_code': material['material_code'],
                      'id_mat': material['id_mat'], // Store id_mat for child material
                    };
                  }

                  // Update the actual quantity
                  selectedMaterials[materialId]!['actual_qty'] = value;
                }
            ),
            _buildDetailField(
                "Batch No",
                "",
                false,
                controller: batchNoController,
                onChanged: (value) {
                  formValues['${materialId}_batch'] = value;

                  // Update or create the selected material entry
                  if (!selectedMaterials.containsKey(materialId)) {
                    selectedMaterials[materialId] = {
                      'id': materialId,
                      'material_desc': material['material_desc'],
                      'material_code': material['material_code'],
                      'id_mat': material['id_mat'], // Store id_mat for child material
                    };
                  }

                  // Update the batch number
                  selectedMaterials[materialId]!['batch_no'] = value;
                }
            ),
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
        Color? fillColor,
        Function(String)? onChanged,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: controller ?? TextEditingController(text: value),
          readOnly: readOnly,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: fillColor != null,
            fillColor: fillColor,
            isDense: true,
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

  // Controllers for dynamic materials
  final Map<String, TextEditingController> batchControllers = {};
  final Map<String, TextEditingController> qtyControllers = {};

  @override
  void dispose() {
    // Dispose all text editing controllers
    for (var controller in batchControllers.values) {
      controller.dispose();
    }
    for (var controller in qtyControllers.values) {
      controller.dispose();
    }

    // Dispose criteria note controllers
    for (var controller in catatanControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget _buildCriteriaTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: criteriaList.map((item) {
        final id = item["id"]!;
        final isRequired = radioSelections[id] == "Tidak";

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
                        Text(
                          item["text"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["translation"]!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
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
                              groupValue: radioSelections[id],
                              onChanged: (value) {
                                setState(() {
                                  radioSelections[id] = value!;
                                });
                              },
                            ),
                            const Text("Ya"),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: "Tidak",
                              groupValue: radioSelections[id],
                              onChanged: (value) {
                                setState(() {
                                  radioSelections[id] = value!;
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
            // Notes Section below each criterion
            if (radioSelections[id] != null) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: catatanControllers[id],
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isRequired
                      ? "Catatan (Wajib diisi)"
                      : "Catatan (Opsional)",
                  labelStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  errorText: isRequired && (catatanControllers[id]?.text.isEmpty ?? true)
                      ? 'Harap isi catatan'
                      : null,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 1, thickness: 1),
          ],
        );
      }).toList(),
    );
  }

  // Add this method to show history dialog
  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Riwayat Pengisian Form",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.existingMaterials.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Tidak ada riwayat pengisian"),
                      ),
                    );
                  }

                  // Group by material and show history
                  final groupedMaterials = <String, List<Map<String, dynamic>>>{};

                  for (var material in controller.existingMaterials) {
                    final materialName = material['material']?['material_desc'] ?? 'Unknown Material';
                    if (!groupedMaterials.containsKey(materialName)) {
                      groupedMaterials[materialName] = [];
                    }
                    groupedMaterials[materialName]!.add(material);
                  }

                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show common data
                          if (controller.existingFormData.value != null) ...[
                            _buildHistoryCommonData(),
                            const Divider(),
                          ],

                          // Show materials history
                          ...groupedMaterials.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...entry.value.map((item) {
                                  final dateStr = item['created_at'] != null
                                      ? DateFormat('dd/MM/yyyy HH:mm').format(
                                      DateTime.parse(item['created_at']))
                                      : 'Unknown date';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Tanggal: $dateStr"),
                                          Text("Batch No: ${item['batch_no'] ?? 'N/A'}"),
                                          Text("Actual Qty: ${item['actual_qty'] ?? 'N/A'}"),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build common data section in history dialog
  Widget _buildHistoryCommonData() {
    final data = controller.existingFormData.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Informasi Umum",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text("Code Task: ${data['code_task'] ?? 'N/A'}"),
        Text("BRM No: ${data['id_brm'] ?? 'N/A'}"),
        const SizedBox(height: 8),
        Text("Sesuai Picklist: ${data['sesuai_picklist'] == true ? 'Ya' : 'Tidak'}"),
        if (data['remarks_picklist']?.isNotEmpty ?? false)
          Text("Catatan Picklist: ${data['remarks_picklist']}"),
        Text("Sesuai Bets: ${data['sesuai_bets'] == true ? 'Ya' : 'Tidak'}"),
        if (data['remarks_bets']?.isNotEmpty ?? false)
          Text("Catatan Bets: ${data['remarks_bets']}"),
        Text("Material Lengkap: ${data['mat_lengkap'] == true ? 'Ya' : 'Tidak'}"),
        if (data['remarks_mat']?.isNotEmpty ?? false)
          Text("Catatan Material: ${data['remarks_mat']}"),
      ],
    );
  }
}
