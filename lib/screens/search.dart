import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_filexplorer/components/file_explorer.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/button.dart';
import 'package:win32/win32.dart';
// ignore: depend_on_referenced_packages
import "package:path/path.dart" as p;

class Search extends StatefulWidget {
  const Search({super.key});
  @override
  State<Search> createState() => _SearchState();
}

Future<List<FileSystemEntity>> listFiles(
    String directoryPath, bool recursive) async {

  if(directoryPath=="C:"){
    recursive=false;
  }
  
  if(recursive && checkFolder(directoryPath)){
    recursive=false;
  }
  final directory = Directory(directoryPath);
  final entities = directory.listSync(recursive: recursive,followLinks: false);
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

class _SearchState extends State<Search> {
  List<FileSystemEntity> result = [];
  bool onlyFolder = false;
  bool onlyFiles = false;
  bool subDir = false;

  Future<void> handle(String query) async {
    List<FileSystemEntity> res = [];
    if (query.trim() != "") {
      final entities =
          await listFiles(context.read<FileProvider>().currentPath, subDir);
      for (final entity in entities) {
        if (entity is File && onlyFiles) {
          String name = p.basenameWithoutExtension(entity.path);
          if (name.trim().toLowerCase().contains(query.trim().toLowerCase())) {
            res.add(entity);
            setState(() {
              result = res;
            });
          }
        } else if (onlyFolder && entity is Directory) {
          String name = p.basenameWithoutExtension(entity.path);
          if (name.trim().toLowerCase().contains(query.trim().toLowerCase())) {
            res.add(entity);
            setState(() {
              result = res;
            });
          }
        } else {
          String name = p.basenameWithoutExtension(entity.path);
          if (name.trim().toLowerCase().contains(query.trim().toLowerCase())) {
            res.add(entity);
            setState(() {
              result = res;
            });
          }
        }
      }
    }
  }

  TextEditingController queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Button btn = Button();
    return Column(
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (val) => handle(queryController.text),
            controller: queryController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              suffix: btn.actionButton(
                () => context.read<FileProvider>().setSearch(false),
                Icons.close,
                "Close",
                hoverColor: AppTheme.accent,
                color: Colors.black,
              ),
              labelText: "Enter the Name of File or Folder",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.accent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.accent,
                ),
              ),
            ),
            autofocus: true,
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            spacing: 10,
            children: [
              btn.actionButton(
                () => setState(() {
                  onlyFolder = !onlyFolder;
                  onlyFiles = false;
                }),
                Icons.folder,
                "Only Folders",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                bgColor: onlyFolder ? AppTheme.accent : Colors.transparent,
              ),
              btn.actionButton(
                () => setState(() {
                  onlyFiles = !onlyFiles;
                  onlyFolder = false;
                }),
                Icons.insert_drive_file,
                "Only Files",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                bgColor: onlyFiles ? AppTheme.accent : Colors.transparent,
              ),
              btn.actionButton(
                () => setState(() {
                  subDir = !subDir;
                }),
                Icons.folder_copy_sharp,
                "Include Sub-Directory",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                bgColor: subDir ? AppTheme.accent : Colors.transparent,
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
            child: ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, index) {
            return Material(
              child: ListTile(
                hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                leading: Icon(result[index] is Directory
                    ? Icons.folder
                    : Icons.insert_drive_file),
                title: Text(
                  result[index] is Directory
                      ? result[index].path.split(Platform.pathSeparator).last
                      : p.basenameWithoutExtension(result[index].path),
                ),
                subtitle:Text(result[index].parent.path),
                trailing: result[index] is Directory
                    ? null
                    : Text(_formatSize(result[index].statSync().size)),
                onTap: () async {
                  if (result[index] is Directory) {
                    context.read<FileProvider>().setSearch(false);
                    await context
                        .read<FileProvider>()
                        .loadFiles(result[index].path);
                  } else {
                    await Process.run(
                        'cmd', ['/c', 'start', '', result[index].path]);
                  }
                },
              ),
            );
          },
        ))
      ],
    );
  }

  static String _formatSize(int size) {
    if (size < 1024) return '$size bytes';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1073741824) return '${(size / 1048576).toStringAsFixed(2)} MB';
    return '${(size / 1073741824).toStringAsFixed(2)} GB';
  }
}
