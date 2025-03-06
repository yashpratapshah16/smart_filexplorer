import 'dart:io';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

class FileProvider extends ChangeNotifier {
  Future<List<FileSystemEntity>> listFiles(String directoryPath) async {
    final directory = Directory(directoryPath);
    final entities = directory.listSync();
    final filteredEntities = entities.where((entity) {
      // Exclude hidden files and folders
      final name = entity.path.split(Platform.pathSeparator).last;
      final isHidden = name.startsWith('.') || _isHiddenFile(entity.path);

      // Exclude system files and folders (e.g., "System Volume Information" on Windows)

      return !isHidden;
    }).toList();
    filteredEntities.sort((a, b) {
      if (a is Directory && b is! Directory) return -1;
      if (a is! Directory && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });

    return filteredEntities;
  }

   bool _isHiddenFile(String path) {
    final attributes = GetFileAttributes(path.toNativeUtf16());
    return attributes & FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_HIDDEN != 0;
  }


  Future<List<String>> listOnlyFolders(String directoryPath) async {
    List<FileSystemEntity> files = await listFiles(directoryPath);
    List<String> onlyFolder = [];
    for (FileSystemEntity file in files) {
      if (file.statSync().type == FileSystemEntityType.directory) {
        onlyFolder.add(file.path.split(Platform.pathSeparator).last);
      }
    }
    return onlyFolder;
  }

  List<FileSystemEntity> files = [];
  String currentPath = r"C:\";
  List<String> frontPath = [];
  List<String> backPath = [];
  int count = 0;
  bool reset = false;

  List<String> filePath(String path) {
    if (path == r"C:\") {
      return [path];
    }
    path = path.replaceAll('/', r'\');

    List<String> splitPaths = [];
    // Split the path by backslash
    List<String> parts = path.split(Platform.pathSeparator);
    String currentpath =
        parts[0] + Platform.pathSeparator; // Start with the drive (e.g., "C:\")
    splitPaths.add(currentpath);

    for (int i = 1; i < parts.length; i++) {
      currentpath += parts[i] + Platform.pathSeparator;
      String path = currentpath.substring(0, currentpath.length - 1);
      if (splitPaths.contains(path) == false) {
        splitPaths.add(path); // Remove trailing backslash
      }
    }
    return splitPaths;
  }

  Future<void> loadFiles(String path) async {
    if (path != "") {
      List<FileSystemEntity> newfiles = await listFiles(path);
      count != 0 ? backPath.add(currentPath) : null;
      if (count != 0) {
        reset = true;
      }
      currentPath = path;
      files = newfiles;
      count++;
      notifyListeners();
    }
  }

  void changeReset() {
    reset = false;
  }

  void goBack() async {
    if (backPath.isNotEmpty) {
      List<FileSystemEntity> newfiles = await listFiles(backPath.last);
      frontPath.add(currentPath);
      currentPath = backPath.last;
      files = newfiles;
      backPath.removeLast();
      if (count != 0) {
        reset = true;
      }
      count--;
      notifyListeners();
    }
  }

  void goFront() async {
    if (frontPath.isNotEmpty) {
      List<FileSystemEntity> newfiles = await listFiles(frontPath.last);
      backPath.add(currentPath);
      currentPath = frontPath.last;
      files = newfiles;
      frontPath.remove(frontPath.last);
      if (count != 0) {
        reset = true;
      }
      count++;
      notifyListeners();
    }
  }
}
