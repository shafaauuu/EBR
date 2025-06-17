import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import '../../../controller/Form/F/form_f_blister_controller.dart';


class PartF_Blister extends StatefulWidget {
  final Task task;

  const PartF_Blister({super.key, required this.task});

  @override
  _PartF_BlisterState createState() => _PartF_BlisterState();
}

class _PartF_BlisterState extends State<PartF_Blister> {
  final TaskDetailsController taskController = Get.put(TaskDetailsController());
  final FormFBlisterController formController = Get.put(FormFBlisterController());

  File? _labelMesinImage;
  File? _label2Image;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    formController.setTaskInfo(widget.task);

    ever(formController.existingFormData, (data) {
      if (data != null) {
        // If we have existing data, we can show it in the UI
        // This would be useful for viewing or editing existing forms
        // But for this form with images, we can't directly display the binary data
      }
    });
  }

  Future<void> _pickLabelMesinImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _labelMesinImage = File(pickedFile.path);
        formController.setLabelMesin(_labelMesinImage!);
      });
    }
  }

  Future<void> _pickLabel2Image(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _label2Image = File(pickedFile.path);
        formController.setLabel2(_label2Image!);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context, bool isLabelMesin) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.question,
        title: "Select Image Source",
        text: "Choose where to get the image from:",
        showCancelBtn: true,
        cancelButtonText: "Gallery",
        confirmButtonText: "Camera",
        onConfirm: () {
          isLabelMesin ? _pickLabelMesinImage(ImageSource.camera) : _pickLabel2Image(ImageSource.camera);
          return true;
        },
        onCancel: () {
          isLabelMesin ? _pickLabelMesinImage(ImageSource.gallery) : _pickLabel2Image(ImageSource.gallery);
          return true;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_labelMesinImage == null || _label2Image == null) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: "Missing Images",
          text: "Please upload both required images",
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await formController.submitForm();

    setState(() {
      _isSubmitting = false;
    });

    if (result) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: formController.successMessage.value,
          onConfirm: () {
            Get.back();
            return true;
          },
        ),
      );
    } else {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: formController.errorMessage.value,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part F. Label Material, Mesin, dan Proses"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => formController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Sticky Header Section
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Image.asset(
                        'assets/logos/logo_oneject.png',
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Batch Record Details (Left)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BATCH RECORD",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildAlignedText("P/C Code", widget.task.code ?? "N/A"),
                          _buildAlignedText("P/C Name", widget.task.name ?? "N/A"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Batch Record Details (Right)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _buildAlignedText("BRM No.", taskController.selectedBRM.value)),
                          _buildAlignedText("Rev No.", ""),
                          _buildAlignedText("Eff. Date", ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // Label Mesin Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Take Photo of Label Mesin",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Label Mesin Photo Field
              GestureDetector(
                onTap: () => _showImageSourceDialog(context, true),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _labelMesinImage == null
                      ? const Center(
                    child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  )
                      : Image.file(_labelMesinImage!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 24),

              // Label 2 Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Take Photo of Second Label",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Label 2 Photo Field
              GestureDetector(
                onTap: () => _showImageSourceDialog(context, false),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _label2Image == null
                      ? const Center(
                    child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  )
                      : Image.file(_label2Image!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
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
}
