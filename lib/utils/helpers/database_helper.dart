// import 'package:flutter/material.dart';
// import 'package:postgres/postgres.dart';
// import 'package:oji_1/features/authentication/models/task_model.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   PostgreSQLConnection? _connection;
//
//   DatabaseHelper._init();
//
//   // Connect to PostgreSQL
//   Future<void> connect() async {
//     if (_connection != null && _connection!.isOpen) {
//       print('PostgreSQL connection is already open.');
//       return;
//     }
//
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'oji_1',
//         username: 'admin',
//         password: 'securepass123',
//       );
//
//       await _connection!.open();
//       print('✅ Connected to PostgreSQL');
//     } catch (e) {
//       print('❌ PostgreSQL Connection Error: $e');
//     }
//   }
//
//   // Disconnect from PostgreSQL
//   Future<void> disconnect() async {
//     if (_connection != null && _connection!.isOpen) {
//       await _connection!.close();
//       print('✅ PostgreSQL connection closed.');
//     }
//   }
//
//   // Fetch tasks from database
//   Future<List<Task>> fetchTasks() async {
//     await connect(); // Ensure connection is established
//
//     try {
//       final results = await _connection!.mappedResultsQuery(
//         'SELECT code, name, icon, color FROM tasks',
//       );
//
//       return results.map((row) => Task.fromMap(row['tasks']!)).toList();
//     } catch (e) {
//       print('❌ Error fetching tasks: $e');
//       return [];
//     }
//   }
//
//   // Insert a task into the database
//   Future<void> insertTask(Task task) async {
//     await connect();
//
//     try {
//       await _connection!.query(
//         'INSERT INTO tasks (code, name, icon, color) VALUES (@code, @name, @icon, @color)',
//         substitutionValues: task.toMap(),
//       );
//       print('✅ Task inserted successfully');
//     } catch (e) {
//       print('❌ Error inserting task: $e');
//     }
//   }
//
//   // Update a task
//   Future<void> updateTask(Task task) async {
//     await connect();
//
//     try {
//       await _connection!.query(
//         'UPDATE tasks SET name = @name, icon = @icon, color = @color WHERE code = @code',
//         substitutionValues: task.toMap(),
//       );
//       print('✅ Task updated successfully');
//     } catch (e) {
//       print('❌ Error updating task: $e');
//     }
//   }
//
//   // Delete a task
//   Future<void> deleteTask(String code) async {
//     await connect();
//
//     try {
//       await _connection!.query(
//         'DELETE FROM tasks WHERE code = @code',
//         substitutionValues: {'code': code},
//       );
//       print('✅ Task deleted successfully');
//     } catch (e) {
//       print('❌ Error deleting task: $e');
//     }
//   }
//
//   void main() async {
//     await connect();
//   }
// }
