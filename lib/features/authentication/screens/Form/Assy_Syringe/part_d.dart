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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
       {'name': 'Temp Nozzle Z1', 'code': 'temp_nozzle_z1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temp Nozzle Z2', 'code': 'temp_nozzle_z2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temp Nozzle Z3', 'code': 'temp_nozzle_z3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temp Nozzle Z4', 'code': 'temp_nozzle_z4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temp Nozzle Z5', 'code': 'temp_nozzle_z5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temp Mold', 'code': 'temp_mold', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Inject Pressure', 'code': 'inject_pressure', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Inject Time', 'code': 'inject_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure', 'code': 'holding_pressure', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Time', 'code': 'holding_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Eject Counter', 'code': 'eject_counter', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Cycle Time', 'code': 'cycle_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Master Batch', 'code': 'masterbatch', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Berat Product', 'code': 'berat_produk', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Berat Runner', 'code': 'berat_runner', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Cavity', 'code': 'cavity', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Sampling', 'code': 'sampling', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Defect', 'code': 'defect', 'controller': null, 'position': 'list', 'type': 'number'},
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
       {'name': 'Forming Time', 'code': 'forming_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Forming Temperature', 'code': 'forming_temperature', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Forming Pressure', 'code': 'forming_pressure', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Sealing Temperature', 'code': 'sealing_temperature', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Sealing Pressure', 'code': 'sealing_pressure', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Sealing Time', 'code': 'sealing_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Cycle Time', 'code': 'cycle_time', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Manufacturing Date', 'code': 'mfg_date', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Expiration Date', 'code': 'exp_date', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Needle Size', 'code': 'needle_size', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'NIE', 'code': 'nie', 'controller': null,'position': 'table', 'type': 'number'},
     ];


   } else if (displayData["machine_type"] == "sgp") {
     parameterRows = [
       {'name': 'Temperature 1', 'code': 'temp1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature 2', 'code': 'temp2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature 3', 'code': 'temp3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature 4', 'code': 'temp4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Load Cap', 'code': 'load_cap', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Load Hub', 'code': 'load_hub', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Load Needle', 'code': 'load_needle', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Hasil Epoxy', 'code': 'hasil_epoxy', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Pressure Actual', 'code': 'pressure_actual', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Pressure Status', 'code': 'pressure_status', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Low Epoxy 1', 'code': 'low_epoxy1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Low Epoxy 2', 'code': 'low_epoxy2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Low Epoxy 3', 'code': 'low_epoxy3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Hub Cannula 1', 'code': 'hub_cannula1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Hub Cannula 2', 'code': 'hub_cannula2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Hub Cannula 3', 'code': 'hub_cannula3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Exc Epoxy 1', 'code': 'exc_epoxy1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Exc Epoxy 2', 'code': 'exc_epoxy2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Exc Epoxy 3', 'code': 'exc_epoxy3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tumpul 1', 'code': 'needle_tumpul1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tumpul 2', 'code': 'needle_tumpul2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tumpul 3', 'code': 'needle_tumpul3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Balik 1', 'code': 'needle_balik1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Balik 2', 'code': 'needle_balik2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Balik 3', 'code': 'needle_balik3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tersumbat 1', 'code': 'needle_tersumbat1', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tersumbat 2', 'code': 'needle_tersumbat2', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Needle Tersumbat 3', 'code': 'needle_tersumbat3', 'controller': null, 'position': 'table', 'type': 'bool'},
       {'name': 'Masterbatch', 'code': 'masterbatch', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Berat Product', 'code': 'berat_product', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Cavity', 'code': 'cavity', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Berat Produk', 'code': 'berat_produk', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Sampling', 'code': 'sampling', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Defect', 'code': 'defect', 'controller': null, 'position': 'table', 'type': 'number'},
     ];

   } else if (displayData["machine_type"] == "fcs") {
     parameterRows = [
       {'name': 'Open Position Slow', 'code': 'open_position_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Fast', 'code': 'open_position_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Mid', 'code': 'open_position_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Dec', 'code': 'open_position_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Speed Slow', 'code': 'open_speed_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Speed Fast', 'code': 'open_speed_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Speed Mid', 'code': 'open_speed_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Speed Dec', 'code': 'open_speed_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Sealing Temperature', 'code': 'sealing_temperature', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Pressure Slow', 'code': 'open_pressure_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Pressure Fast', 'code': 'open_pressure_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Pressure Mid', 'code': 'open_pressure_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Pressure Dec', 'code': 'open_pressure_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Slow', 'code': 'close_position_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Fast', 'code': 'close_position_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Mid', 'code': 'close_position_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Dec', 'code': 'close_position_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Slow', 'code': 'close_speed_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Fast', 'code': 'close_speed_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Mid', 'code': 'close_speed_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Dec', 'code': 'close_speed_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Slow', 'code': 'close_pressure_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Fast', 'code': 'close_pressure_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Mid', 'code': 'close_pressure_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Dec', 'code': 'close_pressure_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Slow', 'code': 'close_position_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Fast', 'code': 'close_position_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Mid', 'code': 'close_position_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Dec', 'code': 'close_position_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Slow', 'code': 'close_speed_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Fast', 'code': 'close_speed_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Mid', 'code': 'close_speed_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Speed Dec', 'code': 'close_speed_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Slow', 'code': 'close_pressure_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Fast', 'code': 'close_pressure_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Mid', 'code': 'close_pressure_mid', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Pressure Dec', 'code': 'close_pressure_dec', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Position Ret2', 'code': 'ejector_position_ret2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Position Ret1', 'code': 'ejector_position_ret1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Position Adv2', 'code': 'ejector_position_adv2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Position Adv1', 'code': 'ejector_position_adv1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Speed Ret2', 'code': 'ejector_speed_ret2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Speed Ret1', 'code': 'ejector_speed_ret1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Speed Adv2', 'code': 'ejector_speed_adv2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Speed Adv1', 'code': 'ejector_speed_adv1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Pressure Ret2', 'code': 'ejector_pressure_ret2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Pressure Ret1', 'code': 'ejector_pressure_ret1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Pressure Adv2', 'code': 'ejector_pressure_adv2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Ejector Pressure Adv1', 'code': 'ejector_pressure_adv1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect1', 'code': 'temperature_sv_sect1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect2', 'code': 'temperature_sv_sect2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect3', 'code': 'temperature_sv_sect3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect4', 'code': 'temperature_sv_sect4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect5', 'code': 'temperature_sv_sect5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Sv Sect6', 'code': 'temperature_sv_sect6', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect1', 'code': 'temperature_pv_sect1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect2', 'code': 'temperature_pv_sect2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect3', 'code': 'temperature_pv_sect3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect4', 'code': 'temperature_pv_sect4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect5', 'code': 'temperature_pv_sect5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pv Sect6', 'code': 'temperature_pv_sect6', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect1', 'code': 'temperature_pre_sect1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect2', 'code': 'temperature_pre_sect2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect3', 'code': 'temperature_pre_sect3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect4', 'code': 'temperature_pre_sect4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect5', 'code': 'temperature_pre_sect5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Pre Sect6', 'code': 'temperature_pre_sect6', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect1', 'code': 'temperature_max_sect1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect2', 'code': 'temperature_max_sect2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect3', 'code': 'temperature_max_sect3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect4', 'code': 'temperature_max_sect4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect5', 'code': 'temperature_max_sect5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Max Sect6', 'code': 'temperature_max_sect6', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect1', 'code': 'temperature_low_sect1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect2', 'code': 'temperature_low_sect2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect3', 'code': 'temperature_low_sect3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect4', 'code': 'temperature_low_sect4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect5', 'code': 'temperature_low_sect5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Low Sect6', 'code': 'temperature_low_sect6', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position Inj5', 'code': 'filling_position_inj5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position Inj4', 'code': 'filling_position_inj4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position Inj3', 'code': 'filling_position_inj3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position Inj2', 'code': 'filling_position_inj2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position Inj1', 'code': 'filling_position_inj1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity Inj5', 'code': 'filling_velocity_inj5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity Inj4', 'code': 'filling_velocity_inj4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity Inj3', 'code': 'filling_velocity_inj3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity Inj2', 'code': 'filling_velocity_inj2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity Inj1', 'code': 'filling_velocity_inj1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Pressure Inj5', 'code': 'filling_pressure_inj5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Pressure Inj4', 'code': 'filling_pressure_inj4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Pressure Inj3', 'code': 'filling_pressure_inj3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Pressure Inj2', 'code': 'filling_pressure_inj2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Pressure Inj1', 'code': 'filling_pressure_inj1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Time Inj5', 'code': 'filling_time_inj5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Time Inj4', 'code': 'filling_time_inj4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Time Inj3', 'code': 'filling_time_inj3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Time Inj2', 'code': 'filling_time_inj2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Time Inj1', 'code': 'filling_time_inj1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Speed Hdp4', 'code': 'holding_speed_hdp4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Speed Hdp3', 'code': 'holding_speed_hdp3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Speed Hdp2', 'code': 'holding_speed_hdp2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Speed Hdp1', 'code': 'holding_speed_hdp1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Hdp4', 'code': 'holding_pressure_hdp4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Hdp3', 'code': 'holding_pressure_hdp3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Hdp2', 'code': 'holding_pressure_hdp2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Hdp1', 'code': 'holding_pressure_hdp1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Back Pre', 'code': 'charging_back_pre', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Back Charge1', 'code': 'charging_back_charge1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Back Charge2', 'code': 'charging_back_charge2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Back Charge3', 'code': 'charging_back_charge3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Back Post', 'code': 'charging_back_post', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Speed Pre', 'code': 'charging_speed_pre', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Speed Charge1', 'code': 'charging_speed_charge1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Speed Charge2', 'code': 'charging_speed_charge2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Speed Charge3', 'code': 'charging_speed_charge3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Speed Post', 'code': 'charging_speed_post', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Pressure Pre', 'code': 'charging_pressure_pre', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Pressure Charge1', 'code': 'charging_pressure_charge1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Pressure Charge2', 'code': 'charging_pressure_charge2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Pressure Charge3', 'code': 'charging_pressure_charge3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Pressure Post', 'code': 'charging_pressure_post', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Position Pre', 'code': 'charging_position_pre', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Position Charge1', 'code': 'charging_position_charge1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Position Charge2', 'code': 'charging_position_charge2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Position Charge3', 'code': 'charging_position_charge3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Charging Position Post', 'code': 'charging_position_post', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Velocity Slow', 'code': 'purge_velocity_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Velocity Fast', 'code': 'purge_velocity_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Velocity Back', 'code': 'purge_velocity_back', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Pressure Slow', 'code': 'purge_pressure_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Pressure Back', 'code': 'purge_pressure_back', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Pressure Fast', 'code': 'purge_pressure_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Position Slow', 'code': 'purge_position_slow', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Position Fast', 'code': 'purge_position_fast', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Purge Position Back', 'code': 'purge_position_back', 'controller': null, 'position': 'table', 'type': 'number'},
     ];

     } else if (displayData["machine_type"] == "shi1") {
     parameterRows = [
       {'name': 'Open Position Openlimit', 'code': 'open_position_openlimit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Second', 'code': 'open_position_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position First', 'code': 'open_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Openlimit', 'code': 'open_velocity_openlimit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Second', 'code': 'open_velocity_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity First', 'code': 'open_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Clamp', 'code': 'close_position_clamp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Second', 'code': 'close_position_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position First', 'code': 'close_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Clamp', 'code': 'close_velocity_clamp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Second', 'code': 'close_velocity_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity First', 'code': 'close_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z1', 'code': 'temperature_z1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z2', 'code': 'temperature_z2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z3', 'code': 'temperature_z3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z4', 'code': 'temperature_z4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z5', 'code': 'temperature_z5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Feeder', 'code': 'temperature_feeder', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position VP', 'code': 'filling_position_vp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position First', 'code': 'filling_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity VP', 'code': 'filling_velocity_vp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity First', 'code': 'filling_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Time Second', 'code': 'holding_time_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Time First', 'code': 'holding_time_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Second', 'code': 'holding_pressure_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure First', 'code': 'holding_pressure_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Pullback Position', 'code': 'plastictizing_pullback_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Pullback Velocity', 'code': 'plastictizing_pullback_velocity', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Position', 'code': 'plastictizing_dose1_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Backpress', 'code': 'plastictizing_dose1_backpress', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Rotation', 'code': 'plastictizing_dose1_rotation', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Position', 'code': 'plastictizing_end_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Backpress', 'code': 'plastictizing_end_backpress', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Rotation', 'code': 'plastictizing_end_rotation', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Forward Position', 'code': 'plastictizing_forward_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Forward Velocity', 'code': 'plastictizing_forward_velocity', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Cooling', 'code': 'plastictizing_cooling', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Masterbatch', 'code': 'masterbatch', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Berat Produk', 'code': 'berat_produk', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Berat Runner', 'code': 'berat_runner', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Cavity', 'code': 'cavity', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Sampling', 'code': 'sampling', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Defect', 'code': 'defect', 'controller': null, 'position': 'list', 'type': 'number'},
     ];

   } else if (displayData["machine_type"] == "shi2") {
     parameterRows = [
       {'name': 'Open Position Openlimit', 'code': 'open_position_openlimit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Forth', 'code': 'open_position_forth', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Third', 'code': 'open_position_third', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position Second', 'code': 'open_position_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Position First', 'code': 'open_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Limit', 'code': 'open_velocity_limit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Forth', 'code': 'open_velocity_forth', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Third', 'code': 'open_velocity_third', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity Second', 'code': 'open_velocity_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Open Velocity First', 'code': 'open_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Limit', 'code': 'close_position_limit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Forth', 'code': 'close_position_forth', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Third', 'code': 'close_position_third', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position Second', 'code': 'close_position_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Position First', 'code': 'close_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Limit', 'code': 'close_velocity_limit', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Forth', 'code': 'close_velocity_forth', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Third', 'code': 'close_velocity_third', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity Second', 'code': 'close_velocity_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Close Velocity First', 'code': 'close_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z1', 'code': 'temperature_z1', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z2', 'code': 'temperature_z2', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z3', 'code': 'temperature_z3', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z4', 'code': 'temperature_z4', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Temperature Z5', 'code': 'temperature_z5', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position VP', 'code': 'filling_position_vp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Position First', 'code': 'filling_position_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity VP', 'code': 'filling_velocity_vp', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Filling Velocity First', 'code': 'filling_velocity_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Time Second', 'code': 'holding_time_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Time First', 'code': 'holding_time_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure Second', 'code': 'holding_pressure_second', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Holding Pressure First', 'code': 'holding_pressure_first', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Pullback Position', 'code': 'plastictizing_pullback_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Pullback Velocity', 'code': 'plastictizing_pullback_velocity', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Position', 'code': 'plastictizing_dose1_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Backpress', 'code': 'plastictizing_dose1_backpress', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Dose1 Rotation', 'code': 'plastictizing_dose1_rotation', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Position', 'code': 'plastictizing_end_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Backpress', 'code': 'plastictizing_end_backpress', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing End Rotation', 'code': 'plastictizing_end_rotation', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Forward Position', 'code': 'plastictizing_forward_position', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Forward Velocity', 'code': 'plastictizing_forward_velocity', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Plastictizing Cooling', 'code': 'plastictizing_cooling', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Masterbatch', 'code': 'masterbatch', 'controller': null, 'position': 'table', 'type': 'number'},
       {'name': 'Berat Produk', 'code': 'berat_produk', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Berat Runner', 'code': 'berat_runner', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Cavity', 'code': 'cavity', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Sampling', 'code': 'sampling', 'controller': null, 'position': 'list', 'type': 'number'},
       {'name': 'Defect', 'code': 'defect', 'controller': null, 'position': 'list', 'type': 'number'},
     ];
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
