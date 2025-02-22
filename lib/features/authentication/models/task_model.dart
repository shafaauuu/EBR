import 'package:flutter/material.dart';

class Task {
  final String code;
  final String name;
  final String? title;
  final IconData icon;
  final Color color;

  Task({
    this.title,
    required this.code,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Convert a database row (Map<String, dynamic>) to a Task object
  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      code: data['code'],
      name: data['name'],
      title: data['title'], // Nullable field
      icon: _mapIcon(data['icon']), // Convert DB string to Flutter IconData
      color: _mapColor(data['color']), // Convert DB string to Flutter Color
    );
  }

  // Convert a Task object to a database-friendly format (Map)
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'title': title,
      'icon': _iconToString(icon), // Convert Flutter IconData to a string
      'color': _colorToString(color), // Convert Flutter Color to a string
    };
  }

  // Convert database icon string to Flutter IconData
  static IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'access_time_filled':
        return Icons.access_time_filled;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  // Convert Flutter IconData to a string for storage
  static String _iconToString(IconData icon) {
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.access_time_filled) return 'access_time_filled';
    if (icon == Icons.warning) return 'warning';
    return 'help_outline';
  }

  // Convert database color string to Flutter Color
  static Color _mapColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Convert Flutter Color to a string for storage
  static String _colorToString(Color color) {
    if (color == Colors.green) return 'green';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    return 'grey';
  }
}
