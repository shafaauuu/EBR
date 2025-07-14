import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../controller/Form/G/form_g_needle_assy_controller.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';

class PartG_NeedleAssy extends StatefulWidget {
  final Task task;

  const PartG_NeedleAssy({super.key, required this.task});

  @override
  _PartG_NeedleAssyState createState() => _PartG_NeedleAssyState();
}

class _PartG_NeedleAssyState extends State<PartG_NeedleAssy> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final FormGNeedleAssyController formController = Get.put(FormGNeedleAssyController());
  final storage = GetStorage();

  late String userRole;
  late String userInisial;

  final TextEditingController remarksController = TextEditingController();

  final SignatureController _signatureController1 = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final SignatureController _signatureController2 = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final SignatureController _signatureController3 = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Variables to store the latest signature images
  Uint8List? latestSignature1;
  Uint8List? latestSignature2;
  Uint8List? latestSignature3;

  // Variables to store the latest form data
  Map<String, dynamic>? latestFormData;

  @override
  void initState() {
    super.initState();
    userRole = storage.read("role") ?? "Production Operation";
    userInisial = storage.read("inisial") ?? "";

    // Set the user's initials based on their role
    if (userRole == "Production Operation") {
      formController.setInisial1(userInisial);
    } else if (userRole == "Head Section") {
      formController.setInisial2(userInisial);
    } else if (userRole == "Assistant Manager") {
      formController.setInisial3(userInisial);
    }

    formController.setTaskInfo(widget.task);
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final formData = await formController.getFormByTaskId(widget.task.id);
    if (formData != null) {
      setState(() {
        latestFormData = formData;
        remarksController.text = formData['remarks'] ?? '';
        formController.setRemarks(remarksController.text);

        latestSignature1 = formController.signature1.value;
        latestSignature2 = formController.signature2.value;
        latestSignature3 = formController.signature3.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Part G. Verifikasi dan Persetujuan"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          Column(
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

              // Scrollable content starts here
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Catatan/Note:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: remarksController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Masukkan catatan di sini...",
                        ),
                        onChanged: (value) {
                          formController.setRemarks(value);
                        },
                      ),
                      const SizedBox(height: 25),
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "Batch Record ini telah diisi sepenuhnya sesuai dengan kondisi sebenarnya.",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "This Batch Record has been completed accurately according to the actual conditions.",
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // First signature section - Operator (always visible)
                      _buildSignatureSection(
                        title: "Tanda Tangan Operator/Operator's Sign:",
                        signatureIndex: 1,
                        onSign: () {
                          _signatureController1.clear();
                          _updateSignatureInController(1, null);
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Second signature section - Head Section (only visible for Head Section role)
                      if (userRole == "Head Section")
                        _buildSignatureSection(
                          title: "Tanda Tangan Kepala Bagian/Head Section's Sign:",
                          signatureIndex: 2,
                          onSign: () {
                            _signatureController2.clear();
                            _updateSignatureInController(2, null);
                          },
                        ),

                      // Show a disabled version for other roles
                      if (userRole != "Head Section")
                        _buildDisabledSignatureSection(
                          title: "Tanda Tangan Kepala Bagian/Head Section's Sign:",
                        ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Third signature section - Assistant Manager (only visible for Assistant Manager role)
                      if (userRole == "Assistant Manager")
                        _buildSignatureSection(
                          title: "Tanda Tangan Asisten Manajer/Assistant Manager's Sign:",
                          signatureIndex: 3,
                          onSign: () {
                            _signatureController3.clear();
                            _updateSignatureInController(3, null);
                          },
                        ),

                      // Show a disabled version for other roles
                      if (userRole != "Assistant Manager")
                        _buildDisabledSignatureSection(
                          title: "Tanda Tangan Asisten Manajer/Assistant Manager's Sign:",
                        ),

                      const SizedBox(height: 16),
                      const Divider(thickness: 2),
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "Halaman Terakhir",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "End of the page",
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _submitForm(context),
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
            ],
          ),

          // Loading overlay
          if (formController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildSignatureSection({
    required String title,
    required int signatureIndex,
    required Function() onSign,
  }) {
    String? rawBase64;
    bool hasSigned = false;
    String initial = "";

    // Get the appropriate signature data based on index
    switch (signatureIndex) {
      case 1:
        rawBase64 = formController.rawSignature1.value;
        hasSigned = latestFormData != null && (latestFormData!['has_signed_1'] == true);
        initial = formController.inisial1.value ?? "";
        break;
      case 2:
        rawBase64 = formController.rawSignature2.value;
        hasSigned = latestFormData != null && (latestFormData!['has_signed_2'] == true);
        initial = formController.inisial2.value ?? "";
        break;
      case 3:
        rawBase64 = formController.rawSignature3.value;
        hasSigned = latestFormData != null && (latestFormData!['has_signed_3'] == true);
        initial = formController.inisial3.value ?? "";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          height: 200,
          width: double.infinity,
          child: hasSigned && rawBase64 != null && rawBase64.isNotEmpty
              ? _buildExistingSignature(rawBase64, signatureIndex, onSign)
              : _buildSignaturePad(signatureIndex),
        ),
        if (hasSigned && latestFormData != null && rawBase64 != null && rawBase64.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            "Date: ${_formatDateTime(latestFormData!['created_at'])}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Inisial/Initial: ", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(width: 8),
              Text(
                initial,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExistingSignature(String base64String, int signatureIndex, Function() onSign) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Signature $signatureIndex'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: _buildSignatureImageForDialog(base64String),
                  ),
                  const SizedBox(height: 16),
                  Text('Date: ${latestFormData != null ? _formatDateTime(latestFormData!['created_at']) : "Unknown"}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    // Update the has_signed flag in the latestFormData
                    if (latestFormData != null) {
                      switch (signatureIndex) {
                        case 1:
                          latestFormData!['has_signed_1'] = false;
                          break;
                        case 2:
                          latestFormData!['has_signed_2'] = false;
                          break;
                        case 3:
                          latestFormData!['has_signed_3'] = false;
                          break;
                      }
                    }
                  });
                  onSign(); // Clear the signature controller
                },
                child: const Text('Sign Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 40),
            const SizedBox(height: 8),
            Text(
              "Signature Available",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Text(
              "(Tap to view)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturePad(int signatureIndex) {
    SignatureController signatureController;
    switch (signatureIndex) {
      case 1:
        signatureController = _signatureController1;
        break;
      case 2:
        signatureController = _signatureController2;
        break;
      case 3:
        signatureController = _signatureController3;
        break;
      default:
        throw Exception("Invalid signature index");
    }

    return Column(
      children: [
        Expanded(
          child: Signature(
            controller: signatureController,
            backgroundColor: Colors.white,
          ),
        ),
        Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clear button
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.blue),
                onPressed: () {
                  signatureController.clear();
                },
                tooltip: 'Clear All',
              ),
              // Undo button
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.blue),
                onPressed: () {
                  signatureController.undo();
                },
                tooltip: 'Undo',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledSignatureSection({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: const Center(
            child: Text(
              "This signature is not available for your role",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Text("Inisial/Initial: ", style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(width: 8),
            Text(
              "N/A",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateSignatureInController(int signatureIndex, Uint8List? imageData) {
    switch (signatureIndex) {
      case 1:
        latestSignature1 = imageData;
        formController.setSignature1(imageData);
        break;
      case 2:
        latestSignature2 = imageData;
        formController.setSignature2(imageData);
        break;
      case 3:
        latestSignature3 = imageData;
        formController.setSignature3(imageData);
        break;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // Capture signatures if not already captured
    if (userRole == "Production Operation" && formController.signature1.value == null && _signatureController1.isNotEmpty) {
      final image1 = await _signatureController1.toPngBytes();
      formController.setSignature1(image1);
    }

    if (userRole == "Head Section" && formController.signature2.value == null && _signatureController2.isNotEmpty) {
      final image2 = await _signatureController2.toPngBytes();
      formController.setSignature2(image2);
    }

    if (userRole == "Assistant Manager" && formController.signature3.value == null && _signatureController3.isNotEmpty) {
      final image3 = await _signatureController3.toPngBytes();
      formController.setSignature3(image3);
    }

    // Submit the form
    final success = await formController.submitForm(context);
    if (success) {
      Get.back(); // Return to previous screen on success
    }
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

  // Helper method to format date time
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  // Try to build an image from base64 string for dialog display
  Widget _buildSignatureImageForDialog(String base64String) {
    try {
      // For data URLs, try to display directly first
      if (base64String.startsWith('data:image')) {
        return Image.network(
          base64String,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print("Network approach failed in dialog: $error");
            // If network approach fails, try extracting base64
            return _tryExtractAndDisplayBase64(base64String);
          },
        );
      } else {
        // For regular base64, try to decode
        return _tryExtractAndDisplayBase64(base64String);
      }
    } catch (e) {
      print("Error in dialog image display: $e");
      return Container(
        alignment: Alignment.center,
        child: Text("Could not display signature image"),
      );
    }
  }

  // Helper method to extract and display base64 data
  Widget _tryExtractAndDisplayBase64(String base64String) {
    try {
      String processedBase64 = base64String;
      if (base64String.startsWith('data:image')) {
        final parts = base64String.split(',');
        if (parts.length > 1) {
          processedBase64 = parts[1];
        }
      }

      // Add padding if needed
      while (processedBase64.length % 4 != 0) {
        processedBase64 += '=';
      }

      final Uint8List bytes = base64Decode(processedBase64);

      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Memory approach failed in dialog: $error");
          return Container(
            alignment: Alignment.center,
            child: Text("Could not display signature image"),
          );
        },
      );
    } catch (e) {
      print("Base64 extraction failed in dialog: $e");
      return Container(
        alignment: Alignment.center,
        child: Text("Could not process signature data"),
      );
    }
  }
}