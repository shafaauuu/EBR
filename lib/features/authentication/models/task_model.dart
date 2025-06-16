import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  final int id;
  final String code;
  final String name;
  final String status;
  final IconData icon;
  final Color color;
  final String brmNo;
  final String assignedBy;
  final String assignedTo;
  final String noBatch;
  final String date;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Adding these fields to prevent errors in TaskDetails
  final String? firstName;
  final String? inisial;
  final String? group;

  Task({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
    required this.brmNo,
    required this.assignedBy,
    required this.assignedTo,
    required this.noBatch,
    required this.date,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.inisial,
    this.group,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parse created_at and updated_at dates
    DateTime? createdAt;
    DateTime? updatedAt;
    
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at']);
      }
      if (json['updated_at'] != null) {
        updatedAt = DateTime.parse(json['updated_at']);
      }
    } catch (e) {
      print('Error parsing dates: $e');
    }
    
    // Format the date for display
    String formattedDate = 'No Date';
    if (createdAt != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);
    }
    
    return Task(
      id: json['id'],
      code: json['product_code'] ?? 'No Code',
      name: json['product_name'] ?? 'Unnamed Task',
      status: json['status'],
      icon: _getStatusIcon(json['status']),
      color: _getStatusColor(json['status']),
      brmNo: json['brm_no'] ?? 'No BRM No',
      assignedBy: json['assigned_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      noBatch: json['no_batch'] ?? '',
      date: formattedDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      // Initialize these fields as null since they're not in the API response
      firstName: null,
      inisial: null,
      group: null,
    );
  }

  static IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ongoing':
        return Icons.schedule;
      case 'pending':
        return Icons.pending_actions;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
