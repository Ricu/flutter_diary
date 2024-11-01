import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:platform/platform.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
// ···

Future<String> get _appDocsPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
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

Future<File> saveText(String text) async{
  final filePath = await datetimeNowFilePath;
  final file = File('$filePath.txt');
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

