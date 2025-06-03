import 'package:flutter/material.dart';

class Task {
  final int id;
  final String code;
  final String name;
  final String status;
  final IconData icon;
  final Color color;

  final String? firstName;
  final String? inisial;
  final String brmNo;
  final String? group;

  final String? date; // <-- Add this field

  Task({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
    required this.brmNo,

    this.firstName,
    this.inisial,
    this.group,
    this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],

      code: json['code'] ?? 'No Code',
      name: json['task_name'] ?? 'Unnamed Task',
      status: json['status'],
      icon: _getStatusIcon(json['status']),
      color: _getStatusColor(json['status']),
      brmNo: json['brm_no'] ?? 'No BRM No',

      inisial: json['inisial'],
      group: json['group'],

      date: json['date'], // <-- Make sure backend sends this (in ISO format)

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

