import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/constants.dart';
import 'package:frc_stategy_app/classes/team.dart';
import 'package:uuid/uuid.dart';

class SemanticLine {
  List<Offset> points;
  Color color;
  bool isVisible;
  Team? team;
  /// The ID is a workaround for the hashing function. 
  /// Because memory hashing will be different between jsonified and non-jsonified objects, 
  /// we need to create hashes based off of SemanticLine fields. 
  /// However, the points arrays can be extremely large and costly to compare 
  /// so UUID is used to check equality and is also included in the JSON.
  final String id;

  static const _uuid = Uuid();

  SemanticLine({
    required this.points,
    required this.color,
    this.isVisible = true,
    this.team,
    String? id, // Optional id parameter
  }) : id = id ?? _uuid.v4(); // Assign id or generate a new one

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color.value,
      'isVisible': isVisible,
      'teamID': team?.id,
      'points': points.map((point) => {'dx': point.dx, 'dy': point.dy}).toList()
    };
  }

  factory SemanticLine.fromJson(Map<String, dynamic> json, List<Team> teams) {
    final points = List<Offset>.from(json['points'].map((point) => Offset(point['dx'], point['dy'])));
    final color = Color(json['color']);
    final isVisible = json['isVisible'];
    final team = teams.firstWhere(
      (team) => team.id == json['teamID'],
      orElse: () => Team(name: 'default', color: Colors.grey),
    );
    final id = json['id'];

    return SemanticLine(
      points: points,
      color: color,
      isVisible: isVisible,
      team: team,
      id: id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SemanticLine && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SemanticLine(id: $id, points: $points, color: $color, isVisible: $isVisible, team: ${team?.name})';
  }
}
