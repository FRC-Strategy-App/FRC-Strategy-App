import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FileManagement {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String folderName, String matchKey, String phase) async {
    final path = await _localPath;
    final folderPath = join(path, folderName);
    await Directory(folderPath).create(recursive: true);
    return File(join(folderPath, '$matchKey-$phase.json'));
  }

  static Future<File> writeMatchData(String folderName, String matchKey, String phase, String data) async {
    final file = await _localFile(folderName, matchKey, phase);
    return file.writeAsString(data);
  }

  static Future<String> readMatchData(String folderName, String matchKey, String phase) async {
    try {
      final file = await _localFile(folderName, matchKey, phase);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
