import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:art_sweetalert/art_sweetalert.dart';


class PartF_NeedleAssy extends StatefulWidget {
  final Task? task;

  const PartF_NeedleAssy({super.key, this.task});

  @override
  _PartF_NeedleAssyState createState() => _PartF_NeedleAssyState();
}

class _PartF_NeedleAssyState extends State<PartF_NeedleAssy> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
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
          _pickImage(ImageSource.camera);
          return true;
        },
        onCancel: () {
          _pickImage(ImageSource.gallery);
          return true;
        },
      ),
    );
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
      body: SingleChildScrollView(
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
                          _buildAlignedText("P/C Code", widget.task?.code ?? "N/A"),
                          _buildAlignedText("P/C Name", widget.task?.name ?? "N/A"),
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
              const SizedBox(height: 16),

              // Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Take Photo of Label",
                  style: TextStyle(
                    fontSize: 14,
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

              const SizedBox(height: 16),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {},
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
}
