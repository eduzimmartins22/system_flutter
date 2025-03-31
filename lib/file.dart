import 'dart:convert';
import 'dart:io';

class FileHelper {
  static Future<File> _getFile(String fileName) async {
    final directory = Directory.current;
    return File('${directory.path}/$fileName.json');
  }

  static Future<List<dynamic>> readData(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (!await file.exists()) return [];
      String content = await file.readAsString();
      return json.decode(content);
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeData(String fileName, List<dynamic> data) async {
    final file = await _getFile(fileName);
    await file.writeAsString(json.encode(data));
  }
}
