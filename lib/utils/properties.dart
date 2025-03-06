import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class Properties {
  static void getProperties(String path, void Function(Map) onUpdate) async {
    Map properties = {
      "Error": "",
      "Name": "Loading...",
      "Type": "Calculating...",
      "Location": "Calculating...",
      "Size": "Calculating...",
      "Last Modified": "Calculating...",
      "Created": "Calculating...",
      "Contains": "Calculating..."
    };

    try {
      final entity =
          FileSystemEntity.isDirectorySync(path) ? Directory(path) : File(path);

      if (await entity.exists()) {
        // Immediate basic info
        properties["Name"] = p.basenameWithoutExtension(path);
        properties["Type"] = entity is Directory ? 'File folder' : 'File';
        properties['Extesnion'] = entity is Directory ? "" : p.extension(path).split(".").last;
        properties["Location"] = entity.parent.path;
        onUpdate(Map.from(properties));

        // Get quick stats
        final stat = await entity.stat();
        properties["Created"] = _formatDate(stat.changed);
        properties["Last Modified"] =
            _formatDate(await _getLastModified(entity));
        onUpdate(Map.from(properties));

        if (entity is Directory) {
          await _calculateWithProgress(entity, properties, onUpdate);
        } else if (entity is File) {
          properties["Size"] = _formatSize(await entity.length());
          onUpdate(Map.from(properties));
        }
      }
    } catch (e) {
      properties["Error"] = "Permission Denied!";
      onUpdate(Map.from(properties));
    }
  }

  static Future<void> _calculateWithProgress(
      Directory dir, Map props, void Function(Map) onUpdate) async {
    int fileCount = 0;
    int folderCount = 1;
    int totalSize = 0;

    void updateContains() {
      props["Contains"] =
          "$fileCount Files, $folderCount Folders (calculating...)";
      onUpdate(Map.from(props));
    }

    await Future.wait([
      _getFolderSize(dir, (size) {
        totalSize += size;
        props["Size"] = "${_formatSize(totalSize)} (calculating...)";
        onUpdate(Map.from(props));
      }).then((finalSize) {
        props["Size"] = _formatSize(finalSize);
        onUpdate(Map.from(props));
      }),
      _getFileCount(dir, onProgress: (count) {
        fileCount = count;
        updateContains();
      }),
      _getFolderCount(dir, onProgress: (count) {
        folderCount = count;
        updateContains();
      })
    ]);

    props["Contains"] = "$fileCount Files, $folderCount Folders";
    onUpdate(Map.from(props));
  }

  static Future<DateTime> _getLastModified(FileSystemEntity entity) async {
    if (entity is File) return await entity.lastModified();
    if (entity is Directory) return (await entity.stat()).modified;
    return DateTime.now();
  }

  static Future<int> _getFolderSize(Directory directory,
      [Function(int)? onProgress]) async {
    int size = 0;
    await for (FileSystemEntity entity in directory.list(recursive: true)) {
      if (entity is File) {
        final fileSize = await entity.length();
        size += fileSize;
        onProgress?.call(size);
      }
    }
    return size;
  }

  static Future<int> _getFileCount(Directory dir,
      {Function(int)? onProgress}) async {
    int count = 0;
    await for (var entity in dir.list(recursive: false)) {
      if (entity is File) {
        count++;
        onProgress?.call(count);
      } else if (entity is Directory) {
        count +=
            await _getFileCount(Directory(entity.path), onProgress: (subCount) {
          onProgress?.call(count + subCount);
        });
      }
    }
    return count;
  }

  static Future<int> _getFolderCount(Directory directory,
      {Function(int)? onProgress}) async {
    int count = 1;
    onProgress?.call(count);
    await for (FileSystemEntity entity in directory.list(recursive: false)) {
      if (entity is Directory) {
        count += await _getFolderCount(Directory(entity.path),
            onProgress: (subCount) {
          onProgress?.call(count + subCount);
        });
        onProgress?.call(count);
      }
    }
    return count;
  }

  static String _formatSize(int size) {
    if (size < 1024) return '$size bytes';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1073741824) return '${(size / 1048576).toStringAsFixed(2)} MB';
    return '${(size / 1073741824).toStringAsFixed(2)} GB';
  }

  static String _formatDate(DateTime date) =>
      DateFormat.yMEd().add_jms().format(date);
}

class PropertiesWindow extends StatefulWidget {
  final String path;

  const PropertiesWindow({super.key, required this.path});

  @override
  State<PropertiesWindow> createState() => _PropertiesWindowState();
}

class _PropertiesWindowState extends State<PropertiesWindow> {
  final Map<dynamic, dynamic> _properties = {};

  @override
  void initState() {
    super.initState();
    Properties.getProperties(widget.path, _updateProperties);
  }

  void _updateProperties(Map newProps) {
    setState(() => _properties
      ..clear()
      ..addAll(newProps));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_properties["Name"] ?? "Properties"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _properties["Type"] == "File"
                ? _buildRow("Extension", _properties["Extesnion"])
                : Text(""),
            _buildRow("Type", _properties["Type"]),
            _buildRow("Location", _properties["Location"]),
            _buildRow("Size", _properties["Size"]),
            _properties["Type"] != "File"
                ? _buildRow("Contains", _properties["Contains"])
                : Text(""),
            _buildRow("Last Modified", _properties["Last Modified"]),
            _buildRow("Created", _properties["Created"]),
            if (_properties["Error"]?.isNotEmpty == true)
              Text(_properties["Error"],
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildRow(String label, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Text(value?.toString() ?? "Calculating...")),
          ],
        ),
      );
}
