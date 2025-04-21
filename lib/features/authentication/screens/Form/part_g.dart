import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/task_details_controller.dart';
import '../../models/task_model.dart';
import 'package:signature/signature.dart';

class PartG extends StatefulWidget {
  final Task? task;

  const PartG({super.key, this.task});

  @override
  _PartGState createState() => _PartGState();
}

class _PartGState extends State<PartG> {
  final TaskDetailsController controller = Get.put(TaskDetailsController());

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan catatan di sini...",
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
              const Text(
                "Tanda Tangan/Sign:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _signatureController,
                  height: 200,
                  backgroundColor: Colors.white,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _signatureController.clear();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final image = await _signatureController.toPngBytes();
                      if (image != null) {
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

              const SizedBox(height: 16),

              const Divider(thickness: 2),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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