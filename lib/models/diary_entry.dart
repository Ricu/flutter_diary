import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Metadata {
  String name; // The name of the metadata
  DateTime date; // The date associated with the metadata

  Metadata({required this.name, required this.date});

  // Convert a Metadata to JSON format
  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
  };

  // Create a Metadata from JSON data
  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      name: json['name'],
      date: DateTime.parse(json['date']),
    );
  }
}


class DiaryEntry {
  String content; // The content of the diary entry
  String mood; // Mood associated with the diary entry
  List<Metadata> metadata; // List of metadata with details

  DiaryEntry({
    required this.content,
    required this.mood,
    required this.metadata,
  });

  // Convert a DiaryEntry to JSON format
  Map<String, dynamic> toJson() => {
    'content': content,
    'mood': mood,
    'metadata': metadata.map((meta) => meta.toJson()).toList(), // Serialize each metadata
  };

  // Create a DiaryEntry from JSON data
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      content: json['content'],
      mood: json['mood'],
      metadata: (json['metadata'] as List).map((metaJson) => Metadata.fromJson(metaJson)).toList(), // Deserialize each metadata
    );
  }
}




class DiaryStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/diary_entries.json');
  }

  Future<File> writeDiaryEntries(List<DiaryEntry> entries) async {
    final file = await _localFile;

    // Convert the list of entries to JSON
    String json = jsonEncode(entries.map((e) => e.toJson()).toList());

    // Write the JSON string to the file
    return file.writeAsString(json);
  }


  // Read diary entries from the file
  Future<List<DiaryEntry>> readDiaryEntries() async {
    try {
      final file = await _localFile;
      
      // Read the file as a string
      String contents = await file.readAsString();
      
      // Decode the JSON string and convert it to a List<DiaryEntry>
      List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.map((json) => DiaryEntry.fromJson(json)).toList();
    } catch (e) {
      // If encountering an error, return an empty list
      return [];
    }
  }
}
