import 'package:flutter/material.dart';

class MaterialModel {
  final String materialCode;
  final String materialDesc;
  final String materialGroup;

  MaterialModel({required this.materialCode, required this.materialDesc, required this.materialGroup});

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      materialCode: json['material_code'],
      materialDesc: json['material_desc'],
      materialGroup: json['material_group'],
    );
  }
}