import 'dart:convert';

import 'package:file/file.dart';
import 'package:frc_stategy_app/classes/constants.dart';
import 'package:frc_stategy_app/classes/semantic_line.dart';
import 'package:frc_stategy_app/classes/team.dart';
import 'package:frc_stategy_app/widgets/field/field_drawing.dart';
import 'package:path/path.dart';

class DrawingData {
  final Map<DrawingPhase, List<SemanticLine>> phaseLines;
  final Map<DrawingPhase, List<SemanticLine>> phaseUndoStack;
  final Map<DrawingPhase, List<SemanticLine>> phaseRedoStack;
  final Map<DrawingPhase, List<SemanticLine>> phaseErasedStack;
  final Map<DrawingPhase, List<SemanticLine>> phaseUndoEraseStack;
  final List<Team> blueAlliance;
  final List<Team> redAlliance;
  String? fileName;

  DrawingData({
    required this.phaseLines,
    required this.phaseUndoStack,
    required this.phaseRedoStack,
    required this.phaseErasedStack,
    required this.phaseUndoEraseStack,
    required this.blueAlliance,
    required this.redAlliance,
    this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': jsonFormatVersion,
      'blueAlliance': blueAlliance.map((team) => team.toJson()).toList(),
      'redAlliance': redAlliance.map((team) => team.toJson()).toList(),
      'phaseLines': phaseLines.map((key, value) => MapEntry(key.toString(), value.map((line) => line.toJson()).toList())),
      'phaseUndoStack': phaseUndoStack.map((key, value) => MapEntry(key.toString(), value.map((line) => line.toJson()).toList())),
      'phaseRedoStack': phaseRedoStack.map((key, value) => MapEntry(key.toString(), value.map((line) => line.toJson()).toList())),
      'phaseErasedStack': phaseErasedStack.map((key, value) => MapEntry(key.toString(), value.map((line) => line.toJson()).toList())),
      'phaseUndoEraseStack': phaseUndoEraseStack.map((key, value) => MapEntry(key.toString(), value.map((line) => line.toJson()).toList())),
    };
  }

  static DrawingData fromJson(Map<String, dynamic> json, {String? fileName}) {
    List<Team> allTeams = [
      ...(json['blueAlliance'] as List).map((team) => Team.fromJson(team)).toList(),
      ...(json['redAlliance'] as List).map((team) => Team.fromJson(team)).toList(),
    ];

    Map<DrawingPhase, List<SemanticLine>> parseLines(Map<String, dynamic> map) {
      return map.map((key, value) => MapEntry(
          DrawingPhase.values.firstWhere((e) => e.toString() == key),
          (value as List).map((line) => SemanticLine.fromJson(line, allTeams)).toList()));
    }

    return DrawingData(
      phaseLines: parseLines(json['phaseLines']),
      phaseUndoStack: parseLines(json['phaseUndoStack']),
      phaseRedoStack: parseLines(json['phaseRedoStack']),
      phaseErasedStack: parseLines(json['phaseErasedStack']),
      phaseUndoEraseStack: parseLines(json['phaseUndoEraseStack']),
      blueAlliance: (json['blueAlliance'] as List).map((team) => Team.fromJson(team)).toList(),
      redAlliance: (json['redAlliance'] as List).map((team) => Team.fromJson(team)).toList(),
      fileName: fileName
    );
  }

  static Future<List<DrawingData>> loadAllDrawingsInDir(String drawingDir, FileSystem fs) async {
    List<DrawingData> drawings = [];

    List<FileSystemEntity> files = fs.directory(drawingDir).listSync();
    for (FileSystemEntity e in files) {
      if (e.path.endsWith('.json')) {
        final file = fs.file(e.path);
        String jsonStr = await file.readAsString();
        try {
          Map<String, dynamic> json = jsonDecode(jsonStr);
          String fileName = basename(e.path);
          // String drawingName = basenameWithoutExtension(e.path);

          DrawingData drawing = DrawingData.fromJson(json, fileName: fileName);
          // drawing.lastModified = (await file.lastModified()).toUtc();

          drawings.add(drawing);
        } catch (ex) {
          // Handle exception
        }
      }
    }
    return drawings;
  }
}
