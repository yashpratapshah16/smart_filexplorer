import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_filexplorer/components/properties.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';

Future<List<FileSystemEntity>> listFiles(String directoryPath) async {
  final directory = Directory(directoryPath);
  return directory.list().toList();
}

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FileExplorerState();
  }
}

class _FileExplorerState extends State<FileExplorer> {
  DateTime? _lastClickTime;
  int _selectedindex = -1;
  @override
  void initState() {
    super.initState();
    context.read<FileProvider>().loadFiles(r"C:\");
  }

  @override
  Widget build(BuildContext context) {
    List<FileSystemEntity> currentFiles = context.watch<FileProvider>().files;
    bool reset = context.watch<FileProvider>().reset;
    final List<Map> menuItems = [
      {
        "name": 'Open',
        "onTap": () => context
            .read<FileProvider>()
            .loadFiles(currentFiles[_selectedindex].path),
      },
      {
        "name": 'Copy',
        "onTap": () {},
      },
      {
        "name": 'Delete',
        "onTap": () {},
      },
      {
        "name": 'Move',
        "onTap": () {},
      },
      {
        "name": 'Properties',
        "onTap": () {
            showDialog(
              context: context,
              builder: (context) => PropertiesWindow(path: currentFiles[_selectedindex].path),
            );
        }
      },
    ];

    void showContextMenu(BuildContext context, Offset position) async {
      await showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          MediaQuery.of(context).size.width - position.dx,
          MediaQuery.of(context).size.height - position.dy,
        ),
        items: menuItems.map((Map item) {
          return PopupMenuItem<String>(
            value: item["name"],
            onTap: item["onTap"],
            child: Row(
              children: [
                Icon(
                  item["name"] == 'Open'
                      ? Icons.folder_open
                      : item["name"] == 'Copy'
                          ? Icons.copy
                          : item["name"] == 'Delete'
                              ? Icons.delete
                              : item["name"] == 'Move'
                                  ? Icons.drive_file_move
                                  : Icons.info,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(item["name"]),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (reset) {
      setState(() {
        _selectedindex = -1;
      });
      context.read<FileProvider>().changeReset();
    }

    void handleMouseClick(PointerDownEvent event, int index) {
      final now = DateTime.now();
      final isDoubleClick = _lastClickTime != null &&
          now.difference(_lastClickTime!) < Duration(milliseconds: 300);

      if (isDoubleClick) {
        if (currentFiles[index].statSync().type ==
            FileSystemEntityType.directory) {
          context.read<FileProvider>().loadFiles(currentFiles[index].path);
        }
        _lastClickTime = null; // Reset after detecting a double-click
        _selectedindex = -1;
      } else {
        setState(() {
          _selectedindex = index;
        });
        if (event.buttons == kPrimaryButton) {
          // print("left");
        } else if (event.buttons == kSecondaryButton) {
          showContextMenu(context, event.position);
        }
        _lastClickTime = now;
      }
    }

    return ListView.builder(
      itemCount: currentFiles.length,
      itemBuilder: (context, index) {
        return Material(
          child: Listener(
            onPointerDown: (PointerDownEvent event) =>
                handleMouseClick(event, index),
            child: ListTile(
              selected: index == _selectedindex,
              selectedColor: Colors.white,
              selectedTileColor: AppTheme.accent.withValues(alpha: 0.8),
              hoverColor: AppTheme.accent.withValues(alpha: 0.5),
              leading: Icon(currentFiles[index].statSync().type ==
                      FileSystemEntityType.directory
                  ? Icons.folder
                  : Icons.insert_drive_file),
              title: Text(
                  currentFiles[index].path.split(Platform.pathSeparator).last),
              onTap: () {},
            ),
          ),
        );
      },
    );
  }
}
