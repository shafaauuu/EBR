import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import '../../../controller/Form/F/form_f_injection_controller.dart';


class PartF_Injection extends StatefulWidget {
  final Task task;

  const PartF_Injection({super.key, required this.task});

  @override
  _PartF_InjectionState createState() => _PartF_InjectionState();
}

class _PartF_InjectionState extends State<PartF_Injection> {
  final TaskDetailsController taskController = Get.put(TaskDetailsController());
  final FormFInjectionController formController = Get.put(FormFInjectionController());

  File? _labelMesinImage;
  File? _label2Image;
  String? _existingLabelMesinImage;
  String? _existingLabel2Image;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isEditMode = false;
  String? _formId;

  @override
  void initState() {
    super.initState();
    formController.setTaskInfo(widget.task);

    ever(formController.existingFormData, (data) {
      if (data != null) {
        setState(() {
          _formId = data['id'].toString();
          _existingLabelMesinImage = data['label_mesin'];
          _existingLabel2Image = data['label_2'];
          _isEditMode = true;
        });
      }
    });
  }

  Future<void> _pickLabelMesinImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _labelMesinImage = File(pickedFile.path);
        _existingLabelMesinImage = null; // Clear existing image when new one is selected
        formController.setLabelMesin(_labelMesinImage!);
      });
      // Close the dialog after picking an image
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickLabel2Image(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _label2Image = File(pickedFile.path);
        _existingLabel2Image = null; // Clear existing image when new one is selected
        formController.setLabel2(_label2Image!);
      });
      // Close the dialog after picking an image
      Navigator.of(context).pop();
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

  // New method to view full-size image
  void _viewFullImage(BuildContext context, bool isLabelMesin) {
    final imageData = isLabelMesin ? _existingLabelMesinImage : _existingLabel2Image;
    final localImage = isLabelMesin ? _labelMesinImage : _label2Image;
    final title = isLabelMesin ? "Label Mesin" : "Second Label";

    if (imageData != null || localImage != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    _showImageSourceDialog(context, isLabelMesin);
                  },
                ),
              ],
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: localImage != null
                    ? Image.file(localImage)
                    : Image.memory(
                  base64Decode(imageData!.split(',').last),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Error loading image', style: TextStyle(color: Colors.red)),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_isEditMode && (_labelMesinImage == null || _label2Image == null)) {
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

    if (_isEditMode && _labelMesinImage == null && _label2Image == null && _existingLabelMesinImage == null && _existingLabel2Image == null) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: "Missing Images",
          text: "Please upload at least one image",
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = _isEditMode && _formId != null
        ? await formController.updateForm(_formId!)
        : await formController.submitForm();

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
          type: ArtSweetAlertType.warning,
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
          : Column(
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
                  child: Image.asset('assets/logos/logo_oneject.png', height: 50),
                ),
                const SizedBox(width: 16),
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
                      _buildAlignedText("P/C Code", widget.task.code ?? "N/A"),
                      _buildAlignedText("P/C Name", widget.task.name ?? "N/A"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAlignedText("BRM No.", widget.task.brmNo ?? ""),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Mesin Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Take Photo of Label Mesin",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_existingLabelMesinImage != null || _labelMesinImage != null)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.blue),
                              onPressed: () => _viewFullImage(context, true),
                              tooltip: "View Full Image",
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showImageSourceDialog(context, true),
                              tooltip: "Update Image",
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Label Mesin Photo Field
                  GestureDetector(
                    onTap: () => (_existingLabelMesinImage != null || _labelMesinImage != null)
                        ? _viewFullImage(context, true)
                        : _showImageSourceDialog(context, true),
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _labelMesinImage != null
                          ? Image.file(_labelMesinImage!, fit: BoxFit.cover)
                          : _existingLabelMesinImage != null
                          ? Image.memory(
                        base64Decode(_existingLabelMesinImage!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Error loading image', style: TextStyle(color: Colors.red)),
                          );
                        },
                      )
                          : const Center(
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Label 2 Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Take Photo of Second Label",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_existingLabel2Image != null || _label2Image != null)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.blue),
                              onPressed: () => _viewFullImage(context, false),
                              tooltip: "View Full Image",
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showImageSourceDialog(context, false),
                              tooltip: "Update Image",
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Label 2 Photo Field
                  GestureDetector(
                    onTap: () => (_existingLabel2Image != null || _label2Image != null)
                        ? _viewFullImage(context, false)
                        : _showImageSourceDialog(context, false),
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _label2Image != null
                          ? Image.file(_label2Image!, fit: BoxFit.cover)
                          : _existingLabel2Image != null
                          ? Image.memory(
                        base64Decode(_existingLabel2Image!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Error loading image', style: TextStyle(color: Colors.red)),
                          );
                        },
                      )
                          : const Center(
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      ),
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
                          : Text(_isEditMode ? "Update" : "Submit", style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
