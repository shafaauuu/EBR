import 'package:flutter/material.dart';

class Task {
  final String code;
  final String name;
  final String status;
  final IconData icon;
  final Color color;

  Task({
    required this.code,
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      code: json['code'] ?? 'No Code',
      name: json['task_name'] ?? 'Unnamed Task',
      status: json['status'],
      icon: _getStatusIcon(json['status']),
      color: _getStatusColor(json['status']),
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
