import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:platform/platform.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '/utils/data_models.dart';
// ···

Future<String> get _appDocsPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}


Future<String> getRecordingOutputPath(DateTime selectedDate, [String? category]) async {
  final docPath = await _appDocsPath;
  final folderName = DateFormat('yyyyMMdd').format(selectedDate);

  final dirPath = '$docPath/$folderName';
  final directory = Directory(dirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final categorySuffix = category != null ? '-$category' : '';
  final hoursMinutesSeconds = DateFormat('HHmmss').format(DateTime.now());
  final fileName = '$folderName-$hoursMinutesSeconds$categorySuffix.mp3';
  final outputPath = '$dirPath/$fileName';

  return outputPath;
}

Future<String> getTextEntryOutputPath(DateTime selectedDate) async {
  final docPath = await _appDocsPath;
  final folderName = DateFormat('yyyyMMdd').format(selectedDate);

  final dirPath = '$docPath/$folderName';
  final directory = Directory(dirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final hoursMinutesSeconds = DateFormat('HHmmss').format(DateTime.now());
  final fileName = '$folderName-$hoursMinutesSeconds.txt';
  final outputPath = '$dirPath/$fileName';

  return outputPath;
}


Future<String> get _datetimeNowFolderPath async {
    final docPath = await _appDocsPath;
    final now = DateTime.now();
    final folderName = DateFormat('yyyyMMdd').format(now);
    return '${docPath}/${folderName}';
}

String get _datetimeNowFileName {
    final now = DateTime.now();
    return DateFormat('yyyyMMdd-HHmmss').format(now);
}

Future<String> get datetimeNowFilePath async {
  final dirPath = await _datetimeNowFolderPath;
  // Ensure the directory exists
  final directory = Directory(dirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  final filePath = '$dirPath/$_datetimeNowFileName';

  return filePath;
}

Future<File> saveText(String text, DateTime selectedDate) async{
  // final filePath = await datetimeNowFilePath;
  final filePath = await getTextEntryOutputPath(selectedDate);
  final file = File(filePath);
  return file.writeAsString(text);
}


Future<List<File>> getLatestTextFiles(int numFiles, int start) async {
  final docPath = await _appDocsPath;
  final directory = Directory(docPath);

  // Retrieve all directories in the document path
  final dateFolders = directory.listSync()
      .whereType<Directory>()
      .where((dir) => RegExp(r'^\d{8}$').hasMatch(dir.path.split('/').last))
      .toList();
  print("Number of date folders: ${dateFolders.length}");
  // Sort folders in descending order based on their date in folder name
  dateFolders.sort((a, b) => b.path.compareTo(a.path));

  // Collect text files from each folder until we reach k files
  
  final allFiles = <File>[];
  for (final folder in dateFolders) {
    // Retrieve and sort all text files in the current folder
    final filesInFolder = folder
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.txt'))
        .toList();

    // Sort files in descending order based on their creation time in filename
    filesInFolder.sort((a, b) => b.path.compareTo(a.path));

    // Add files from this folder to allFiles
    allFiles.addAll(filesInFolder);
  }
  
  // Add `numFiles` files to the list of latest files, starting from the one with index `start`
  final latestFiles = <File>[];
  for (int i = start; i < start + numFiles && i < allFiles.length; i++) {
    latestFiles.add(allFiles[i]);
  }

  return latestFiles;
}



Future<File?> exportAllEntriesToZip() async {
  try {
    final platform = LocalPlatform();

    // Determine the target directory path (Downloads on Android, Documents on iOS)
    Directory? downloadDirectory;
    if (platform.isAndroid) {
      downloadDirectory = await getExternalStorageDirectory();
      if (downloadDirectory != null) {
        downloadDirectory = Directory(
            path.join(downloadDirectory.parent.parent.parent.parent.path, 'Download'));
      }
    } else if (platform.isIOS) {
      downloadDirectory = await getApplicationDocumentsDirectory();
    }

    if (downloadDirectory == null) {
      print('Could not access the target directory.');
      return null;
    }

    // Access the ApplicationDocumentsDirectory where all files are stored
    final appDocDir = await getApplicationDocumentsDirectory();
    final archive = Archive();

    // Recursively add files and retain folder structure
    void addDirectoryToArchive(Directory directory, String basePath) {
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is File) {
          // Create a relative path by removing the base path from the file's absolute path
          final relativePath = path.relative(entity.path, from: basePath);
          final fileBytes = entity.readAsBytesSync(); 
          archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
        }
      }
    }

    addDirectoryToArchive(appDocDir, appDocDir.path);

    // Encode the archive to a ZIP file
    final zipEncoder = ZipEncoder();
    final zipFilePath = path.join(downloadDirectory.path, 'journal_entries.zip');
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipEncoder.encode(archive)!);

    return zipFile;
  } catch (e) {
    print('Error exporting entries to zip: $e');
    return null;
  }
}

// ##########################################
// SQLITE implementation
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'diary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE DiaryEntry (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date DATETIME NOT NULL,
            text TEXT,
            audio_files_references TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE CategoryContent (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            diary_entry_id INTEGER NOT NULL,
            identifier TEXT NOT NULL,
            display_name TEXT NOT NULL,
            data TEXT,
            text TEXT,
            FOREIGN KEY (diary_entry_id) REFERENCES DiaryEntry (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}


Future<int> insertDiaryEntry(DiaryEntry entry) async {
  final db = await DatabaseHelper().database;

  // Insert the main DiaryEntry and retrieve its ID
  final diaryEntryId = await db.insert('DiaryEntry', entry.toMap());

  // Insert associated categories
  for (var category in entry.categories) {
    category.diaryEntryId = diaryEntryId; // Associate with the diary entry
    await db.insert('CategoryContent', category.toMap());
  }

  return diaryEntryId;
}

Future<List<DiaryEntry>> getLastEntries({required int limit, required int offset}) async {
  final db = await DatabaseHelper().database;

  // Fetch a limited number of diary entries with an offset for pagination
  final diaryEntries = await db.query(
    'DiaryEntry',
    orderBy: 'date DESC',
    limit: limit,
    offset: offset,
  );

  // For each diary entry, fetch associated categories
  return Future.wait(diaryEntries.map((entry) async {
    final categories = await db.query(
      'CategoryContent',
      where: 'diary_entry_id = ?',
      whereArgs: [entry['id']],
    );

    return DiaryEntry.fromMap(
      entry,
      categories.map((cat) => CategoryContent.fromMap(cat)).toList(),
    );
  }).toList());
}


Future<DiaryEntry?> getDiaryEntry(int id) async {
  final db = await DatabaseHelper().database;

  // Fetch the diary entry
  final diaryEntries = await db.query(
    'DiaryEntry',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (diaryEntries.isEmpty) return null;

  // Fetch associated categories
  final categories = await db.query(
    'CategoryContent',
    where: 'diary_entry_id = ?',
    whereArgs: [id],
  );

  return DiaryEntry.fromMap(
    diaryEntries.first,
    categories.map((cat) => CategoryContent.fromMap(cat)).toList(),
  );
}

Future<int> updateDiaryEntry(DiaryEntry entry) async {
  final db = await DatabaseHelper().database;

  // Update the main DiaryEntry
  await db.update(
    'DiaryEntry',
    entry.toMap(),
    where: 'id = ?',
    whereArgs: [entry.id],
  );

  // Delete old categories for the entry
  await db.delete(
    'CategoryContent',
    where: 'diary_entry_id = ?',
    whereArgs: [entry.id],
  );

  // Insert updated categories
  for (var category in entry.categories) {
    category.diaryEntryId = entry.id; // Ensure the correct association
    await db.insert('CategoryContent', category.toMap());
  }

  return entry.id!;
}

Future<void> deleteDiaryEntry(int id) async {
  final db = await DatabaseHelper().database;

  // Delete the diary entry and associated categories (CASCADE ensures this works)
  await db.delete(
    'DiaryEntry',
    where: 'id = ?',
    whereArgs: [id],
  );
}