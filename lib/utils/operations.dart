// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:smart_filexplorer/utils/snackbar_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

class Operations {
  static bool _isHiddenFile(String path) {
    final attributes = GetFileAttributes(path.toNativeUtf16());
    return attributes & FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_HIDDEN != 0
        ? false
        : true;
  }

  static Future<bool> createDirectory(String directoryPath) async {
    try {
      Directory directory = Directory(directoryPath);
      await directory.create(
        recursive: true,
      ); // recursive: true creates parent directories if they don't exist
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createFile(String path) async {
    try {
      File file = File(path);
      await file.create(
          recursive:
              true); // `recursive: true` creates parent directories if they don't exist
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteFile(String path) async {
    // Delete the file
    try {
      File file = File(path);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteDirectory(String directoryPath) async {
    try {
      Directory directory = Directory(directoryPath);
      await directory.delete(
        recursive: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> copyFile(
    String sourceFilePath,
    String destinationFilePath,
    int incremnet,
  ) async {
    try {
      if (File(destinationFilePath).existsSync()) {
        String name = path.basenameWithoutExtension(sourceFilePath);
        String extension = path.extension(sourceFilePath);
        List<String> paths = path.split(destinationFilePath);
        paths.remove(paths.last);
        destinationFilePath = "";
        destinationFilePath = path.joinAll(paths);
        destinationFilePath +=
            "${Platform.pathSeparator}$name(${incremnet + 1})$extension";
        copyFile(sourceFilePath, destinationFilePath, incremnet + 1);
      }
      File sourceFile = File(sourceFilePath);
      await sourceFile.copy(destinationFilePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> copyFolder(
    String sourceFolderPath,
    String destinationFolderPath,
    int incremnet,
  ) async {
    try {
      if (Directory(destinationFolderPath).existsSync()) {
        String name = sourceFolderPath.split(Platform.pathSeparator).last;
        List<String> paths = path.split(destinationFolderPath);
        paths.remove(paths.last);
        destinationFolderPath = path.joinAll(paths);
        destinationFolderPath +=
            "${Platform.pathSeparator}$name(${incremnet + 1})";
        copyFolder(
          sourceFolderPath,
          destinationFolderPath,
          incremnet + 1,
        );
      }
      Directory destinationDir = Directory(destinationFolderPath);
      await destinationDir.create(recursive: true);

      Directory sourceDir = Directory(sourceFolderPath);
      List<FileSystemEntity> entities = sourceDir.listSync(recursive: true);

      for (int i = 0; i < entities.length; i++) {
        final entity = entities[i];
        if (_isHiddenFile(entity.path)) {
          String relativePath = entity.path.substring(sourceFolderPath.length);
          String newPath = destinationFolderPath + relativePath;
          if (entity is File) {
            File(newPath).existsSync()
                ? null
                : await File(entity.path).copy(newPath);
          } else if (entity is Directory) {
            Directory(newPath).existsSync()
                ? null
                : await Directory(newPath).create(recursive: true);
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> moveEntity(String src, String dest, bool type) async {
    try {
      // print("$src\n$dest");
      if (type) {
        File move = File(src);
        await move.copy(dest);
        await move.delete();
        return true;
      } else {
        Directory destinationDir = Directory(dest);
        await destinationDir.create(recursive: true);

        Directory sourceDir = Directory(src);
        List<FileSystemEntity> entities = sourceDir.listSync(recursive: true);

        for (int i = 0; i < entities.length; i++) {
          final entity = entities[i];
          if (_isHiddenFile(entity.path)) {
            String relativePath = entity.path.substring(src.length);
            String newPath = dest + relativePath;
            if (entity is File) {
              File(newPath).existsSync()
                  ? null
                  : await File(entity.path).copy(newPath);
            } else if (entity is Directory) {
              Directory(newPath).existsSync()
                  ? null
                  : await Directory(newPath).create(recursive: true);
            }
          }
        }
        await sourceDir.delete(recursive: true);
        return true;
      }
    } catch (e) {
      // print(e);
      return false;
    }
  }

  static Future<void> renameEntity(String path, String name, String newname,
      bool type, BuildContext context) async {
    if (type) {
      newname += ".${name.split(".").last}";
      try {
        File rename = File("$path${Platform.pathSeparator}$name");
        await rename.rename("$path${Platform.pathSeparator}$newname");
        SnackbarUtils.showSnackbar(context, Icons.error, "File Renamed.");
      } catch (e) {
        SnackbarUtils.showSnackbar(context, Icons.error, "Error Accured!");
      }
    } else {
      try {
        Directory rename = Directory("$path${Platform.pathSeparator}$name");
        await rename.rename("$path${Platform.pathSeparator}$newname");
        SnackbarUtils.showSnackbar(context, Icons.error, "Folder Renamed.");
      } catch (e) {
        SnackbarUtils.showSnackbar(context, Icons.error, "Error Accured!");
      }
    }
  }
}
