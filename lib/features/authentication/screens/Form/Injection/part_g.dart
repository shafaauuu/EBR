import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task_details_controller.dart';
import '../../../models/task_model.dart';
import 'package:signature/signature.dart';
import '../../../controller/Form/G/form_g_injection_controller.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class PartG_Injection extends StatefulWidget {
  final Task task;

  const PartG_Injection({super.key, required this.task});

  @override
  _PartG_InjectionState createState() => _PartG_InjectionState();
}

class _PartG_InjectionState extends State<PartG_Injection> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());
  final FormGInjectionController formController = Get.put(FormGInjectionController());
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

    if (widget.task != null) {
      formController.setTaskInfo(widget.task!);
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    if (widget.task?.id != null) {
      final formData = await formController.getFormByTaskId(widget.task!.id!);
      if (formData != null) {
        setState(() {
          latestFormData = formData;
          remarksController.text = formData['remarks'] ?? '';
          formController.setRemarks(remarksController.text);

          // Store the latest signatures from the controller
          latestSignature1 = formController.signature1.value;
          latestSignature2 = formController.signature2.value;
          latestSignature3 = formController.signature3.value;
        });
      }
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
                      Center(
                        child: Column(
                          children: const [
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
                        signatureController: _signatureController1,
                        inisial: userRole == "Production Operation" ? userInisial : "",
                        signatureIndex: 1,
                        isEnabled: userRole == "Production Operation",
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Second signature section - Head Section (only visible for Head Section role)
                      if (userRole == "Head Section")
                        _buildSignatureSection(
                          title: "Tanda Tangan Kepala Bagian/Head Section's Sign:",
                          signatureController: _signatureController2,
                          inisial: userInisial,
                          signatureIndex: 2,
                          isEnabled: true,
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
                          signatureController: _signatureController3,
                          inisial: userInisial,
                          signatureIndex: 3,
                          isEnabled: true,
                        ),

                      // Show a disabled version for other roles
                      if (userRole != "Assistant Manager")
                        _buildDisabledSignatureSection(
                          title: "Tanda Tangan Asisten Manajer/Assistant Manager's Sign:",
                        ),

                      const SizedBox(height: 16),
                      const Divider(thickness: 2),
                      Center(
                        child: Column(
                          children: const [
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
    required SignatureController signatureController,
    required String inisial,
    required int signatureIndex,
    required bool isEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: isEnabled ? Colors.grey : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AbsorbPointer(
            absorbing: !isEnabled,
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: Signature(
                controller: signatureController,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isEnabled)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  signatureController.clear();
                  _updateSignatureInController(signatureIndex, null);
                },
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text("Clear", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final image = await signatureController.toPngBytes();
                  if (image != null) {
                    _updateSignatureInController(signatureIndex, image);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Signature Preview"),
                        content: Image.memory(image),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.visibility),
                label: const Text("Preview"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Inisial/Initial: ", style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              inisial,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Display the latest signature if available
        _buildSignatureDisplay(signatureIndex),
      ],
    );
  }

  // Custom widget to display signature with fallback mechanisms
  Widget _buildSignatureDisplay(int signatureIndex) {
    Uint8List? signatureBytes;
    String? rawBase64;

    // Get the appropriate signature data based on index
    switch (signatureIndex) {
      case 1:
        signatureBytes = latestSignature1;
        rawBase64 = formController.rawSignature1.value;
        break;
      case 2:
        signatureBytes = latestSignature2;
        rawBase64 = formController.rawSignature2.value;
        break;
      case 3:
        signatureBytes = latestSignature3;
        rawBase64 = formController.rawSignature3.value;
        break;
    }

    // If no signature data available, return empty container
    if (signatureBytes == null && rawBase64 == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Previous Signature:",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildSignatureImageWithFallback(signatureBytes, rawBase64),
        ),
        if (latestFormData != null) ...[
          const SizedBox(height: 4),
          Text(
            "Date: ${_formatDateTime(latestFormData!['created_at'])}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // Build signature image with fallback mechanisms
  Widget _buildSignatureImageWithFallback(Uint8List? signatureBytes, String? rawBase64) {
    // First try: Use the decoded Uint8List if available
    if (signatureBytes != null) {
      return Image.memory(
        signatureBytes,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Error displaying signature from bytes: $error");
          // If Image.memory fails, try with base64 string
          return _buildBase64Image(rawBase64);
        },
      );
    }
    // Second try: Use the raw base64 string
    else if (rawBase64 != null) {
      return _buildBase64Image(rawBase64);
    }
    // Fallback: Show placeholder
    else {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text("Signature not available", style: TextStyle(color: Colors.grey)),
      );
    }
  }

  // Build image from base64 string
  Widget _buildBase64Image(String? base64String) {
    if (base64String == null) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text("Signature data not available", style: TextStyle(color: Colors.grey)),
      );
    }

    // For web platform, use HTML approach which can handle problematic base64 data better
    if (kIsWeb) {
      // Create a data URL for the image
      final dataUrl = 'data:image/png;base64,$base64String';

      // Create a unique ID for this image
      final imageId = 'signature-image-${DateTime.now().millisecondsSinceEpoch}';

      // Create an HTML image element
      final imageElement = html.ImageElement()
        ..id = imageId
        ..src = dataUrl
        ..style.height = '150px'
        ..style.objectFit = 'contain';

      // Add the image to the DOM temporarily
      html.document.body?.append(imageElement);

      // Use HtmlElementView to display the HTML element in Flutter
      return SizedBox(
        height: 150,
        child: Builder(
          builder: (BuildContext context) {
            // Schedule to remove the element when this widget is disposed
            Future.delayed(Duration.zero, () {
              // Create a canvas to draw the image to
              try {
                final canvas = html.CanvasElement(width: imageElement.width, height: imageElement.height);
                final ctx = canvas.context2D;

                // Draw the image to the canvas
                ctx.drawImage(imageElement, 0, 0);

                // Replace the original image with the canvas-rendered version
                imageElement.src = canvas.toDataUrl('image/png');
              } catch (e) {
                print('Error rendering image through canvas: $e');
              }
            });

            return HtmlElementView(viewType: imageId);
          },
        ),
      );
    }

    // For non-web platforms, use the standard Flutter approach
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Image.memory(
        base64Decode(base64String),
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Error displaying signature from base64: $error");
          // Final fallback: Show placeholder with error message
          return Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text(
                  "Could not display signature",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
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
    if (userRole == "Production Operation" && formController.signature1.value == null && !_signatureController1.isEmpty) {
      final image1 = await _signatureController1.toPngBytes();
      formController.setSignature1(image1);
    }

    if (userRole == "Head Section" && formController.signature2.value == null && !_signatureController2.isEmpty) {
      final image2 = await _signatureController2.toPngBytes();
      formController.setSignature2(image2);
    }

    if (userRole == "Assistant Manager" && formController.signature3.value == null && !_signatureController3.isEmpty) {
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
}