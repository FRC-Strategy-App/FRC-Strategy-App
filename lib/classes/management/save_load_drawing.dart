import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frc_stategy_app/classes/semantic_line.dart';
import 'package:frc_stategy_app/classes/team.dart';

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String generateFilename(String? eventKey, String? matchKey) {
  if (eventKey == null || matchKey == null) {
    return 'Untitled Drawing';
  } else {
    return '$eventKey/$matchKey';
  }
}

Future<File> getLocalFile(String? eventKey, String? matchKey) async {
  final path = await getLocalPath();
  String fileName = generateFilename(eventKey, matchKey);
  return File('$path/$fileName.json');
}

Future<Map<String, dynamic>> loadDrawing() async {
  try {
    final String? path = await getOpenPath();
    if (path == null) {
      // Operation was canceled by the user.
      return {};
    }
    final file = File(path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      return jsonDecode(contents)..['filePath'] = path; // Add filePath to the returned data
    }
  } catch (e) {
    print("Error loading drawing data: $e");
  }
  return {};
}


Future<String?> saveDrawing(String? eventKey, String? matchKey, Map<String, dynamic> data) async {
  final String? path = await getLocalSavePath(suggestedName: generateFilename(eventKey, matchKey));
  if (path == null) {
    // Operation was canceled by the user.
    return null;
  }

  // Ensure the file has a .json extension
  String filePath = path.endsWith('.json') ? path : '$path.json';

  final file = File(filePath);
  await file.writeAsString(jsonEncode(data));

  return filePath;
}


Future<String?> getLocalSavePath({String? suggestedName}) async {
  const XTypeGroup typeGroup = XTypeGroup(
    label: 'json',
    extensions: ['json'],
  );

  final String? path = await getSavePath(
    suggestedName: suggestedName,
    acceptedTypeGroups: [typeGroup],
    initialDirectory: await getLocalPath(),
  );
  return path;
}


Future<String?> getOpenPath() async {
  const XTypeGroup typeGroup = XTypeGroup(
    label: 'json',
    extensions: ['json'],
  );

  final XFile? file = await openFile(
    acceptedTypeGroups: [typeGroup],
    initialDirectory: await getLocalPath(),
  );

  return file?.path;
}

