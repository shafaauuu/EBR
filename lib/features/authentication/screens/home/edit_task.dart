import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/models/task_model.dart';
import 'package:oji_1/features/authentication/controller/task_controller.dart';

class EditTask extends StatefulWidget {
  final Task task;
  
  const EditTask({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _batchController;
  late TextEditingController _dateController;
  late String _status;
  final TaskController taskController = Get.find<TaskController>();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _codeController = TextEditingController(text: widget.task.code);
    _batchController = TextEditingController(text: widget.task.brmNo);
    _dateController = TextEditingController(text: widget.task.date ?? '');
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _batchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please rotate your device to landscape mode.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product/Component Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Task Code
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Product/Component Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Batch Number
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(
                  labelText: 'BRM No',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a BRM number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Date
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>['ongoing', 'pending', 'completed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalizeFirst ?? value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              SizedBox(height: 32),
              
              // Save Button
              Center(
                child: _isLoading 
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                      ),
                      child: Text('Save Changes'),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Call the updateTask method in TaskController
        final success = await taskController.updateTask(
          widget.task.id,
          _nameController.text,
          _codeController.text,
          _batchController.text,
          _dateController.text,
          _status
        );
        
        if (success) {
          // Show success message
          Get.snackbar(
            'Success',
            'Task updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Go back to previous screen
          Get.back();
        } else {
          // Show error message
          Get.snackbar(
            'Error',
            'Failed to update task',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Error',
          'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
