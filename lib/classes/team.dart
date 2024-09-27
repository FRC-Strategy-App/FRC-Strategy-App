import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/constants.dart';
import 'package:uuid/uuid.dart';

class Team {
  String name;
  Color color;
  bool isVisible;
  final String id;

  static const uuid = Uuid();

  Team({required this.name, required this.color, this.isVisible = true, String? id})
      : id = id ?? uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'color': color.value,
      'isVisible': isVisible,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      color: Color(json['color']),
      isVisible: json['isVisible'],
      id: json['id'], // Accept id from JSON if it exists
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Team &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Team(id: $id, name: $name, color: $color, isVisible: $isVisible)';
  }
}