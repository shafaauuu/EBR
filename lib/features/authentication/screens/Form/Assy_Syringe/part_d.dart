import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../../../controller/Form/D/form_d_assysyringe_controller.dart';
import 'material_reconciliation.dart';

class PartD extends StatefulWidget {
  final Task task;
  final String selectedMaterialCode;
  const PartD({super.key, required this.task, required this.selectedMaterialCode});

  @override
  _PartDState createState() => _PartDState();
}

class _PartDState extends State<PartD> {
  Uint8List? _webImage;
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final FormDAssySyringeController formDController = Get.put(FormDAssySyringeController());

  TextEditingController actualRunningController = TextEditingController();
  TextEditingController runAwalController = TextEditingController();
  TextEditingController defectController = TextEditingController();
  TextEditingController goodsOkController = TextEditingController();
  TextEditingController goodsRejectController = TextEditingController();
  List<Map<String, dynamic>> parameterRows = [];


  List<bool> _siapRunningChecks = [false, false, false]; // for Barrel, Plunger, Gasket

  dynamic displayData = null;
  String displayType = '';

  String? _selectedMachine;
  DateTime? _selectedDateTime;
  String? _lineClearance; // 'YA' or 'TIDAK'

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the BRM number from the task controller
      String brmNo = controller.selectedBRM.value;
      // Fetch machines by task
      getForm();
      // formDController.getMachinesByTask(brmNo, widget.task.id);
    });
  }
  Future<void> getForm() async {
   displayData = await formDController.getForm(widget.task.id.toString());
   if (displayData["machine_type"] == "fcs_shi") {
     parameterRows = [
       {'name': 'Temp Nozzle Z1', 'code': 'temp_nozzle_z1', 'controller': null},
       {'name': 'Temp Nozzle Z2', 'code': 'temp_nozzle_z2', 'controller': null},
       {'name': 'Temp Nozzle Z3', 'code': 'temp_nozzle_z3', 'controller': null},
       {'name': 'Temp Nozzle Z4', 'code': 'temp_nozzle_z4', 'controller': null},
       {'name': 'Temp Nozzle Z5', 'code': 'temp_nozzle_z5', 'controller': null},
       {'name': 'Temp Mold', 'code': 'temp_mold', 'controller': null},
       {'name': 'Inject Pressure', 'code': 'inject_pressure', 'controller': null},
       {'name': 'Inject Time', 'code': 'inject_time', 'controller': null},
       {'name': 'Holding Pressure', 'code': 'holding_pressure', 'controller': null},
       {'name': 'Holding Time', 'code': 'holding_time', 'controller': null},
       {'name': 'Eject Counter', 'code': 'eject_counter', 'controller': null},
       {'name': 'Cycle Time', 'code': 'cycle_time', 'controller': null},
     ];


   } else if (displayData["machine_type"] == "assy") {
     // Add Assy parameters
     parameterRows = [
       {'name': 'Print Machine Speed', 'code': 'print_match_speed', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Assy Machine Speed', 'code': 'assy_match_speed', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Actual Running', 'code': 'actual_running', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Run Awal', 'code': 'run_awal', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Defect', 'code': 'defect', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Goods Ok', 'code': 'goods_ok', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Goods Reject', 'code': 'goods_reject', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Load Gasket', 'code': 'load_gasket', 'controller': null, 'position': 'list', 'type': 'bool'},
       {'name': 'Load Plunger', 'code': 'load_plunger', 'controller': null, 'position': 'list', 'type': 'bool'},
       {'name': 'Load Barrel', 'code': 'load_barrel', 'controller': null, 'position': 'list', 'type': 'bool'},
     ];

   } else if (displayData["machine_type"] == "blister") {
     // Add Blister parameters
     parameterRows = [
       {'name': 'Forming Time', 'code': 'forming_time', 'controller': null},
       {'name': 'Forming Temperature', 'code': 'forming_temperature', 'controller': null},
       {'name': 'Forming Pressure', 'code': 'forming_pressure', 'controller': null},
       {'name': 'Sealing Temperature', 'code': 'sealing_temperature', 'controller': null},
       {'name': 'Sealing Pressure', 'code': 'sealing_pressure', 'controller': null},
       {'name': 'Sealing Time', 'code': 'sealing_time', 'controller': null},
       {'name': 'Cycle Time', 'code': 'cycle_time', 'controller': null},
       {'name': 'Manufacturing Date', 'code': 'mfg_date', 'controller': null},
       {'name': 'Expiration Date', 'code': 'exp_date', 'controller': null},
       {'name': 'Needle Size', 'code': 'needle_size', 'controller': null},
       {'name': 'NIE', 'code': 'nie', 'controller': null},
     ];


   // } else if (isSgp || machineType == 'sgp') {
   //   // Add SGP parameters
   //   parameterRows = [
   //     {'name': 'Material Type', 'code': 'material_type', 'controller': null},
   //     {'name': 'Mold Temperature', 'code': 'mold_temperature', 'controller': null},
   //     {'name': 'Injection Pressure', 'code': 'injection_pressure', 'controller': null},
   //     {'name': 'Injection Speed', 'code': 'injection_speed', 'controller': null},
   //     {'name': 'Holding Pressure', 'code': 'holding_pressure', 'controller': null},
   //     {'name': 'Holding Time', 'code': 'holding_time', 'controller': null},
   //     {'name': 'Cooling Time', 'code': 'cooling_time', 'controller': null},
   //     {'name': 'Temperature 1', 'code': 'temp1', 'controller': null},
   //     {'name': 'Temperature 2', 'code': 'temp2', 'controller': null},
   //     {'name': 'Temperature 3', 'code': 'temp3', 'controller': null},
   //     {'name': 'Temperature 4', 'code': 'temp4', 'controller': null},
   //   ];
   //
   //   // Set controller values
   // } else if (isShi1 || isShi2) {
   //   // Add SHI-1 or SHI-2 parameters
   //   parameterRows = [
   //     // Open Position parameters
   //     {'name': 'Open Position - Open Limit', 'code': 'open_position_openlimit', 'controller': null},
   //     {'name': 'Open Position - Second', 'code': 'open_position_second', 'controller': null},
   //     {'name': 'Open Position - First', 'code': 'open_position_first', 'controller': null},
   //
   //     // Open Velocity parameters
   //     {'name': 'Open Velocity - Open Limit', 'code': 'open_velocity_openlimit', 'controller': null},
   //     {'name': 'Open Velocity - Second', 'code': 'open_velocity_second', 'controller': null},
   //     {'name': 'Open Velocity - First', 'code': 'open_velocity_first', 'controller': null},
   //
   //     // Close Position parameters
   //     {'name': 'Close Position - Clamp', 'code': 'close_position_clamp', 'controller': null},
   //     {'name': 'Close Position - Second', 'code': 'close_position_second', 'controller': null},
   //     {'name': 'Close Position - First', 'code': 'close_position_first', 'controller': null},
   //
   //     // Close Velocity parameters
   //     {'name': 'Close Velocity - Clamp', 'code': 'close_velocity_clamp', 'controller': null},
   //     {'name': 'Close Velocity - Second', 'code': 'close_velocity_second', 'controller': null},
   //     {'name': 'Close Velocity - First', 'code': 'close_velocity_first', 'controller': null},
   //
   //     // Ejector parameters
   //     {'name': 'Ejector Position - Eject', 'code': 'ejector_position_eject', 'controller': null},
   //     {'name': 'Ejector Position - First', 'code': 'ejector_position_first', 'controller': null},
   //     {'name': 'Ejector Velocity - Eject', 'code': 'ejector_velocity_eject', 'controller': null},
   //     {'name': 'Ejector Velocity - First', 'code': 'ejector_velocity_first', 'controller': null},
   //
   //     // Temperature parameters
   //     {'name': 'Temperature Z1', 'code': 'temperature_z1', 'controller': null},
   //     {'name': 'Temperature Z2', 'code': 'temperature_z2', 'controller': null},
   //     {'name': 'Temperature Z3', 'code': 'temperature_z3', 'controller': null},
   //     {'name': 'Temperature Z4', 'code': 'temperature_z4', 'controller': null},
   //     {'name': 'Temperature Z5', 'code': 'temperature_z5', 'controller': null},
   //     {'name': 'Temperature Feeder', 'code': 'temperature_feeder', 'controller': null},
   //
   //     // Purging parameters
   //     {'name': 'Purging Z1', 'code': 'purging_z1', 'controller': null},
   //     {'name': 'Purging Z2', 'code': 'purging_z2', 'controller': null},
   //     {'name': 'Purging Z3', 'code': 'purging_z3', 'controller': null},
   //     {'name': 'Purging Z4', 'code': 'purging_z4', 'controller': null},
   //     {'name': 'Purging Z5', 'code': 'purging_z5', 'controller': null},
   //     {'name': 'Purging Feeder', 'code': 'purging_feeder', 'controller': null},
   //
   //     // Filling parameters
   //     {'name': 'Filling Position VP', 'code': 'filling_position_vp', 'controller': null},
   //     {'name': 'Filling Position First', 'code': 'filling_position_first', 'controller': null},
   //     {'name': 'Filling Velocity VP', 'code': 'filling_velocity_vp', 'controller': null},
   //     {'name': 'Filling Velocity First', 'code': 'filling_velocity_first', 'controller': null},
   //     {'name': 'Filling Pressure', 'code': 'filling_pressure', 'controller': null},
   //     {'name': 'Fill Time Limit', 'code': 'fill_time_limit', 'controller': null},
   //
   //     // Holding parameters
   //     {'name': 'Holding Time Second', 'code': 'holding_time_second', 'controller': null},
   //     {'name': 'Holding Time First', 'code': 'holding_time_first', 'controller': null},
   //     {'name': 'Holding Pressure Second', 'code': 'holding_pressure_second', 'controller': null},
   //     {'name': 'Holding Pressure First', 'code': 'holding_pressure_first', 'controller': null},
   //     {'name': 'Holding Velocity', 'code': 'holding_velocity', 'controller': null},
   //
   //     // Plasticizing parameters
   //     {'name': 'Plasticizing Pullback Position', 'code': 'plastictizing_pullback_position', 'controller': null},
   //     {'name': 'Plasticizing Pullback Velocity', 'code': 'plastictizing_pullback_velocity', 'controller': null},
   //     {'name': 'Plasticizing Dose1 Position', 'code': 'plastictizing_dose1_position', 'controller': null},
   //     {'name': 'Plasticizing Dose1 Backpress', 'code': 'plastictizing_dose1_backpress', 'controller': null},
   //     {'name': 'Plasticizing Dose1 Rotation', 'code': 'plastictizing_dose1_rotation', 'controller': null},
   //     {'name': 'Plasticizing Dose2 Position', 'code': 'plastictizing_dose2_position', 'controller': null},
   //     {'name': 'Plasticizing Dose2 Backpress', 'code': 'plastictizing_dose2_backpress', 'controller': null},
   //     {'name': 'Plasticizing Dose2 Rotation', 'code': 'plastictizing_dose2_rotation', 'controller': null},
   //     {'name': 'Plasticizing End Position', 'code': 'plastictizing_end_position', 'controller': null},
   //     {'name': 'Plasticizing End Backpress', 'code': 'plastictizing_end_backpress', 'controller': null},
   //     {'name': 'Plasticizing End Rotation', 'code': 'plastictizing_end_rotation', 'controller': null},
   //     {'name': 'Plasticizing Forward Position', 'code': 'plastictizing_forward_position', 'controller': null},
   //     {'name': 'Plasticizing Forward Velocity', 'code': 'plastictizing_forward_velocity', 'controller': null},
   //     {'name': 'Plasticizing Cooling', 'code': 'plastictizing_cooling', 'controller': null},
   //     {'name': 'Plasticizing Time Limit', 'code': 'plastictizing_time_limit', 'controller': null},
   //   ];
   //
   }
   for (var row in parameterRows) {
     String code = row['code'];
     if (formDController.parameterControllers[code] == null) {
       formDController.parameterControllers[code] = TextEditingController(text: displayData['machine_value']?[code]?.toString() ?? '');
     }
     row['controller'] = formDController.parameterControllers[code];
   }


   setState(() {

     if (displayData != null) {
       displayType = displayData['material_type'] ?? 
                    displayData['material'] ?? 
                    'Unknown Material';
     } else {
       displayType = 'No data available';
     }
   });
  }

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

  void _navigateToMaterialReconciliation() async {
    final result = await Get.to(() => MaterialReconciliationAssySyringe(
      task: widget.task,
      selectedMaterialCode: widget.selectedMaterialCode,
    ));
    
    // If material reconciliation was completed successfully, you can handle it here
    if (result == true) {
      // Maybe show a success message or update some state
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print for machine type
    print('Debug - Selected Machine Type: ${formDController.selectedMachineType.value}');
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
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Sudah'),
                          value: 'Sudah',
                          groupValue: _lineClearance,
                          onChanged: (String? value) {
                            setState(() {
                              _lineClearance = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Belum'),
                          value: 'Belum',
                          groupValue: _lineClearance,
                          onChanged: (String? value) {
                            setState(() {
                              _lineClearance = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // const Text(
                  //   "Mesin yang Digunakan:",
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.blue,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Obx(() {
                  //   return DropdownButtonFormField<String>(
                  //     value: _selectedMachine,
                  //     items: formDController.machineList.map((machine) {
                  //       return DropdownMenuItem(
                  //         value: machine['id_machine'].toString(),
                  //         child: Text(machine['machine_name'] ?? 'Unknown Machine'),
                  //       );
                  //     }).toList(),
                  //     onChanged: (value) {
                  //       setState(() {
                  //         _selectedMachine = value;
                  //
                  //         if (value != null) {
                  //           // Reset status checks and actual values when machine changes
                  //           formDController.statusChecks.clear();
                  //           formDController.actualValues.clear();
                  //
                  //           // Fetch machine display data when machine is selected
                  //           formDController.getMachineDisplayData(
                  //             int.parse(value),
                  //             controller.selectedBRM.value
                  //           ).then((_) {
                  //             // Update controllers with the fetched display data
                  //             actualRunningController.text = formDController.actualRunning.value;
                  //             runAwalController.text = formDController.runAwal.value;
                  //             defectController.text = formDController.defect.value;
                  //             goodsOkController.text = formDController.goodsOk.value;
                  //             goodsRejectController.text = formDController.goodsReject.value;
                  //
                  //             // Update checkbox states
                  //             setState(() {
                  //               _siapRunningChecks[0] = formDController.loadBarrel.value;
                  //               _siapRunningChecks[1] = formDController.loadPlunger.value;
                  //               _siapRunningChecks[2] = formDController.loadGasket.value;
                  //             });
                  //           });
                  //         }
                  //       },
                  //     },
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8)),
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           horizontal: 12, vertical: 16),
                  //     ),
                  //     hint: const Text("Pilih Mesin"),
                  //   );
                  // }),
                  // const SizedBox(height: 30),

                  // Material Used - Only show after machine is selected
                  if (displayData != null) ...[
                    const Text(
                      "Material yang Digunakan:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "Material Type: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(displayType),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],

                  // Machine Parameters Table - Only show after machine is selected
                  if (displayData != null) ...[
                    const Text(
                      "Parameter Mesin:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      // if (formDController.isLoading.value) {
                      //   return const Center(child: CircularProgressIndicator());
                      // }
                      
                      // // Find the selected machine in the filtered list
                      // final selectedMachineId = int.parse(_selectedMachine!);
                      // final selectedMachineData = formDController.filteredMachineDisplays
                      //     .firstWhere(
                      //       (machine) => machine['machine_id'] == selectedMachineId,
                      //       orElse: () => {},
                      //     );
                      
                      if (displayData == null) {
                        return const Center(
                          child: Text("No parameter data available for this machine"),
                        );
                      }
                      
                      return buildVerticalParametersTable();
                    }),
                    const SizedBox(height: 30),
                  ],

                  // Production Data fields with machine-specific sections
                    if (parameterRows.isNotEmpty &&
                        parameterRows.where((entry) => entry["position"] == "list").isNotEmpty) ...[
                       Column(
                        children: [
                          sectionTitle("Production Data"),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                ...parameterRows
                                    .asMap()
                                    .entries
                                    .where((entry) =>
                                entry.value["position"] == "list" && entry.value["type"] == "number")
                                    .map((entry) => buildFormField(
                                    entry.value["name"],
                                    entry.value["controller"]))
                                    .toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...parameterRows
                              .asMap()
                              .entries
                              .where((entry) =>
                          entry.value["position"] == "list" && entry.value["type"] == "bool")
                              .map((entry) => buildCheckBoxField(
                              entry.value["name"],
                              entry.value["controller"].text == "true",
                              (value) {
                                setState(() {
                                  parameterRows[entry.key]["controller"].text = value.toString();
                                });
                              }))
                              .toList(),

                        ],
                      ),
                  ],
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

                  // Buttons Row - Material Reconciliation and Submit side by side
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      // Material Reconciliation Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToMaterialReconciliation,
                                icon: const Icon(Icons.inventory),
                                label: const Text("Open Material Reconciliation"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Submit Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitPartD,
                                icon: const Icon(Icons.check_circle),
                                label: const Text("Submit Form D"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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

  void _submitPartD() async {
    // Validation removed as requested

    // Parse machine ID from selected value
    int machineId = int.tryParse(_selectedMachine ?? '1') ?? 1;

    // Get machine type from the selected machine
    final selectedMachineData = formDController.machineList.firstWhereOrNull(
      (machine) => machine['id_machine'].toString() == _selectedMachine
    );
    final machineType = selectedMachineData?['machine_type'] ?? 'assy'; // Default to 'assy' if not found


    final storage = GetStorage();


    // Submit the form based on machine type
    await formDController.submitForm(
      machineId: machineId,
      type: displayData['form_type'],
      brmNo: controller.selectedBRM.value,
      materialType: machineType == 'blister' ? formDController.materialType.value :
                   machineType == 'sgp' ? formDController.materialType.value : "Syringe",
      codeTask: widget.task.code,
      shift: storage.read("group") ?? "",
      taskId: widget.task.id,
      tanggal: _selectedDateTime ?? DateTime.now(),
      // For Assy machine
      loadBarrel: _siapRunningChecks[0],
      loadPlunger: _siapRunningChecks[1],
      loadGasket: _siapRunningChecks[2],
      // For Blister machine
      formingTime: machineType == 'blister' ? formDController.formingTime.value : '',
      formingTemperature: machineType == 'blister' ? formDController.formingTemperature.value : '',
      formingPressure: machineType == 'blister' ? formDController.formingPressure.value : '',
      sealingTemperature: machineType == 'blister' ? formDController.sealingTemperature.value : '',
      sealingPressure: machineType == 'blister' ? formDController.sealingPressure.value : '',
      sealingTime: machineType == 'blister' ? formDController.sealingTime.value : '',
      cycleTime: machineType == 'blister' ? formDController.cycleTime.value : '',
      mfgDate: machineType == 'blister' ? formDController.mfgDate.value : '',
      expDate: machineType == 'blister' ? formDController.expDate.value : '',
      needleSize: machineType == 'blister' ? formDController.needleSize.value : '',
      nie: machineType == 'blister' ? formDController.nie.value : '',
      // For SGP machine
      moldTemperature: machineType == 'sgp' ? formDController.moldTemperature.value : '',
      injectionPressure: machineType == 'sgp' ? formDController.injectionPressure.value : '',
      injectionSpeed: machineType == 'sgp' ? formDController.injectionSpeed.value : '',
      holdingPressure: machineType == 'sgp' ? formDController.holdingPressure.value : '',
      holdingTime: machineType == 'sgp' ? formDController.holdingTime.value : '',
      coolingTime: machineType == 'sgp' ? formDController.coolingTime.value : '',
      temp1: machineType == 'sgp' ? formDController.temp1.value : '',
      temp2: machineType == 'sgp' ? formDController.temp2.value : '',
      temp3: machineType == 'sgp' ? formDController.temp3.value : '',
      temp4: machineType == 'sgp' ? formDController.temp4.value : '',
      loadCap: machineType == 'sgp' ? formDController.loadCap.value : false,
      loadHub: machineType == 'sgp' ? formDController.loadHub.value : false,
      loadNeedle: machineType == 'sgp' ? formDController.loadNeedle.value : false,
      hasilEpoxy: machineType == 'sgp' ? formDController.hasilEpoxy.value : false,
      pressureActual: machineType == 'sgp' ? formDController.pressureActual.value : '',
      pressureStatus: machineType == 'sgp' ? formDController.pressureStatus.value : false,
      lowEpoxy1: machineType == 'sgp' ? formDController.lowEpoxy1.value : false,
      lowEpoxy2: machineType == 'sgp' ? formDController.lowEpoxy2.value : false,
      lowEpoxy3: machineType == 'sgp' ? formDController.lowEpoxy3.value : false,
      hubCanula1: machineType == 'sgp' ? formDController.hubCanula1.value : false,
      hubCanula2: machineType == 'sgp' ? formDController.hubCanula2.value : false,
      hubCanula3: machineType == 'sgp' ? formDController.hubCanula3.value : false,
      excEpoxy1: machineType == 'sgp' ? formDController.excEpoxy1.value : false,
      excEpoxy2: machineType == 'sgp' ? formDController.excEpoxy2.value : false,
      excEpoxy3: machineType == 'sgp' ? formDController.excEpoxy3.value : false,
      needleTumpul1: machineType == 'sgp' ? formDController.needleTumpul1.value : false,
      needleTumpul2: machineType == 'sgp' ? formDController.needleTumpul2.value : false,
      needleTumpul3: machineType == 'sgp' ? formDController.needleTumpul3.value : false,
      needleBalik1: machineType == 'sgp' ? formDController.needleBalik1.value : false,
      needleBalik2: machineType == 'sgp' ? formDController.needleBalik2.value : false,
      needleBalik3: machineType == 'sgp' ? formDController.needleBalik3.value : false,
      needleTersumbat1: machineType == 'sgp' ? formDController.needleTersumbat1.value : false,
      needleTersumbat2: machineType == 'sgp' ? formDController.needleTersumbat2.value : false,
      needleTersumbat3: machineType == 'sgp' ? formDController.needleTersumbat3.value : false,
      // Common production data
      actualRunning: actualRunningController.text,
      runAwal: machineType == 'sgp' ? runAwalController.text : '', // For SGP, runAwal is used for cycle time
      defect: defectController.text,
      goodsOk: goodsOkController.text,
      goodsReject: goodsRejectController.text,
      machinePicture: _image,
      lineClearance: _lineClearance ?? 'Sudah',
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

  Widget buildFormField(dynamic label, TextEditingController controller) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildCheckBoxField(dynamic label, bool value, Function(bool?) onChanged) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: Checkbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalParametersTable() {
    // Get machine name
    final machineName = displayData['machine']?['machine_name'] ?? 'Unknown';
    var machineData = displayData;
    
    // Create parameter rows based on machine type
    // Detect machine type
    bool isFcsShi = machineData.containsKey('temp_nozzle_z1');
    bool isAssy = machineData.containsKey('print_mach_speed');
    bool isShi1 = machineData.containsKey('open_position_openlimit') || 
                 machineData.containsKey('temperature_z1') ||
                 machineData.containsKey('purging_z1');
    bool isShi2 = machineData.containsKey('open_position_openlimit') || 
                 machineData.containsKey('temperature_z1') ||
                 machineData.containsKey('purging_z1');
    bool isBlister = machineData.containsKey('forming_time') || 
                    machineData.containsKey('forming_temperature') ||
                    machineData.containsKey('forming_pressure');
    bool isSgp = machineData.containsKey('mold_temperature') || 
                machineData.containsKey('injection_pressure') ||
                machineData.containsKey('injection_speed');

    // Get machine type from the machine data
    String machineType = machineData['machine_type'] ?? '';

    // Set controller values


    
    // Initialize the status checks list in the state
    if (formDController.statusChecks.isEmpty) {
      formDController.statusChecks.value = List.generate(parameterRows.length, (_) => false);
      formDController.actualValues.value = List.generate(parameterRows.length, (_) => '');
    }


    return Center(
      child: Container(
        width: double.infinity,
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1.5),  // Machine Name
            1: FlexColumnWidth(1.5),  // Parameter Name
            2: FlexColumnWidth(1.5),  // Parameter Value
            3: FlexColumnWidth(1.5),  // Actual
            4: FlexColumnWidth(1),    // Status
          },
          children: [
            // Header row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
              children: [
                'Machine Name',
                'Parameter Name',
                'Parameter Value',
                'Actual',
                'Status',
              ].map((header) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  header,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )).toList(),
            ),
            
            // Parameter rows
            ...parameterRows.asMap().entries.where((entry) => entry.value['position'] == 'table').map((entry) {
              final index = entry.key;
              final param = entry.value;
              
              return TableRow(
                children: [
                  // Machine Name (only show in first row)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      index == 0 ? machineName : '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Parameter Name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(param['name'] ?? ''),
                  ),
                  // Parameter Value
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(param['value'] ?? ''),
                  ),
                  // Actual (input field)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: TextFormField(
                      controller: param['controller'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (value) {
                        // Store the actual value for validation
                        if (index < formDController.actualValues.length) {
                          formDController.actualValues[index] = value;
                        }
                      },
                    ),
                  ),
                  // Status (checkbox)
                  Center(
                    child: Checkbox(
                      value: index < formDController.statusChecks.length ? formDController.statusChecks[index] : false,
                      onChanged: (value) {
                        setState(() {
                          if (index < formDController.statusChecks.length) {
                            formDController.statusChecks[index] = value ?? false;
                          }
                        });
                      },
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
}
