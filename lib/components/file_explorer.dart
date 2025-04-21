// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/operations.dart';
import 'package:smart_filexplorer/utils/properties.dart';
import 'package:smart_filexplorer/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<FileSystemEntity>> listFiles(String directoryPath) async {
  final directory = Directory(directoryPath);
  return directory.list().toList();
}

void openFile(String filePath, BuildContext context) async {
  try {
    await Process.run('cmd', ['/c', 'start', '', filePath]);
  } catch (e) {
    SnackbarUtils.showSnackbar(context, Icons.error, "Cannot Open This File");
  }
}

void handleDelete(String path, bool isFile, BuildContext context) async {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text("Delete"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure want to Delete The '${path.split(Platform.pathSeparator).last}'",
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            String currentPath = context.read<FileProvider>().currentPath;
            if (isFile) {
              if (await Operations.deleteFile(path)) {
                SnackbarUtils.showSnackbar(
                    context, Icons.delete, "File Deleted!");
                await context.read<FileProvider>().loadFiles(currentPath);
              } else {
                SnackbarUtils.showSnackbar(
                    context, Icons.error, "Error Accured!");
              }
            } else {
              if (await Operations.deleteDirectory(path)) {
                SnackbarUtils.showSnackbar(
                    context, Icons.delete, "Folder Deleted!");
                await context.read<FileProvider>().loadFiles(currentPath);
              } else {
                SnackbarUtils.showSnackbar(
                    context, Icons.error, "Error Accured!");
              }
            }
            Navigator.pop(context);
          },
          child: Text("Delete"),
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

bool checkFolder(String path) {
  if (path.contains(r"C:\Windows")) {
    return true;
  } else if (path == r"C:\Users") {
    return true;
  } else if (path.contains(r"C:\Users\Public")) {
    return true;
  } else if (path == r"C:\Boot") {
    return true;
  } else if (path == r"C:\Recovery") {
    return true;
  } else if (path == r"C:\Intel") {
    return true;
  } else if (path == r"C:\AMD") {
    return true;
  } else if (path == r"C:\Drivers") {
    return true;
  } else if (path.contains(r"C:\PerfLogs")) {
    return true;
  } else if (path.contains(r"C:\Program Files")) {
    return true;
  } else if (path.contains(r"C:\Program Files (x86)")) {
    return true;
  } else if (path.contains(r"C:\ProgramData")) {
    return true;
  } else if (path == Platform.environment["USERPROFILE"]) {
    return true;
  }
  return false;
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
    context.read<FileProvider>().loadFiles(context.read<FileProvider>().currentPath);
  }

  @override
  Widget build(BuildContext context) {
    List<FileSystemEntity> currentFiles = context.watch<FileProvider>().files;
    bool reset = context.watch<FileProvider>().reset;
    bool isGrid = context.watch<FileProvider>().isGrid;

    void showProgressDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Pasting..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
              ),
            ],
          ),
        ),
      );
    }

    final List<Map> menuItems = [
      {
        "name": 'Open',
        "onTap": () {
          if (currentFiles[_selectedindex] is Directory) {
            context
                .read<FileProvider>()
                .loadFiles(currentFiles[_selectedindex].path);
          } else {
            openFile(currentFiles[_selectedindex].path, context);
          }
        },
      },
      {
        "name": 'Rename',
        "onTap": () async {
          if (checkFolder(currentFiles[_selectedindex].path)) {
            SnackbarUtils.showSnackbar(context, Icons.error,
                "You cannot A Rename this Folder Or File");
          } else {
            String name = currentFiles[_selectedindex]
                .path
                .split(Platform.pathSeparator)
                .last;
            TextEditingController nameController = TextEditingController();
            Future<void> handle() async {
              if (currentFiles[_selectedindex] is File) {
                await Operations.renameEntity(
                  currentFiles[_selectedindex].parent.path,
                  name,
                  nameController.text,
                  true,
                  context,
                );
              } else {
                await Operations.renameEntity(
                  currentFiles[_selectedindex].parent.path,
                  name,
                  nameController.text,
                  false,
                  context,
                );
              }
              context
                  .read<FileProvider>()
                  .loadFiles(currentFiles[_selectedindex].parent.path);
              Navigator.pop(context);
            }

            await showDialog<void>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("Rename"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter the Name of $name",
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
                        controller: nameController,
                        autofocus: true,
                        onSubmitted: (String value) => handle(),
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: handle,
                    child: Text("Rename"),
                  ),
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        },
      },
      {
        "name": "Paste",
        "onTap": () async {
          String path = context.read<FileProvider>().selectedPath;
          String curpath = context.read<FileProvider>().currentPath;

          if (path.isNotEmpty) {
            bool copy = context.read<FileProvider>().copyOrNOt;
            final entity = FileSystemEntity.isDirectorySync(path)
                ? Directory(path)
                : File(path);
            if (copy) {
              if (entity is Directory) {
                showProgressDialog(context);
                try {
                  final success = await Operations.copyFolder(
                    path,
                    "$curpath${Platform.pathSeparator}${path.split(Platform.pathSeparator).last}",
                    0,
                  );

                  Navigator.pop(context); // Dismiss dialog

                  if (success) {
                    context.read<FileProvider>().loadFiles(curpath);
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.copy,
                      "Folder Copied.",
                    );
                    context.read<FileProvider>().resetSelecteIndex();
                    context.read<FileProvider>().resetSelectedPath();
                  } else {
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.error,
                      "Error Occurred!",
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  SnackbarUtils.showSnackbar(
                    context,
                    Icons.error,
                    "Error: ${e.toString()}",
                  );
                }
              } else {
                showProgressDialog(context);
                try {
                  final success = await Operations.copyFile(
                    path,
                    "$curpath${Platform.pathSeparator}${path.split(Platform.pathSeparator).last}",
                    0,
                  );
                  Navigator.pop(context); // Dismiss dialog
                  if (success) {
                    context.read<FileProvider>().loadFiles(curpath);
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.copy,
                      "File Copied.",
                    );
                    context.read<FileProvider>().resetSelecteIndex();
                    context.read<FileProvider>().resetSelectedPath();
                  } else {
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.error,
                      "Error Accured!",
                    );
                  }
                } catch (e) {
                  SnackbarUtils.showSnackbar(
                    context,
                    Icons.error,
                    "Error Accured!",
                  );
                }
              }
            } else {
              final entity = FileSystemEntity.isDirectorySync(path)
                  ? Directory(path)
                  : File(path);

              final paths = p.split(curpath);
              bool condition1 = false;

              for (final val in paths) {
                if (val == p.split(path).last) {
                  condition1 = true;
                  break;
                }
              }

              bool condition2 = false;

              String destPath =
                  "$curpath${Platform.pathSeparator}${path.split(Platform.pathSeparator).last}";

              if (entity is Directory) {
                if (Directory(destPath).existsSync()) {
                  condition2 = true;
                }
              } else {
                if (File(destPath).existsSync()) {
                  condition2 = true;
                }
              }

              if (curpath == entity.parent.path ||
                  curpath == path ||
                  condition1 && entity is Directory ||
                  condition2) {
                SnackbarUtils.showSnackbar(
                  context,
                  Icons.error,
                  "Cannot Move File or Folder On Same Directory OR Sub-Directory",
                );
              } else {
                if (entity is Directory) {
                  showProgressDialog(context);
                  try {
                    final success =
                        await Operations.moveEntity(path, destPath, false);
                    Navigator.pop(context); // Dismiss dialog
                    if (success) {
                      context.read<FileProvider>().loadFiles(curpath);
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.copy,
                        "Folder Moved.",
                      );
                      context.read<FileProvider>().resetSelecteIndex();
                      context.read<FileProvider>().resetSelectedPath();
                    } else {
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.error,
                        "Error Occurred!",
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.error,
                      "Error: ${e.toString()}",
                    );
                  }
                } else {
                  showProgressDialog(context);
                  try {
                    final success =
                        await Operations.moveEntity(path, destPath, true);
                    Navigator.pop(context); // Dismiss dialog
                    if (success) {
                      context.read<FileProvider>().loadFiles(curpath);
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.copy,
                        "File Moved.",
                      );
                      context.read<FileProvider>().resetSelecteIndex();
                      context.read<FileProvider>().resetSelectedPath();
                    } else {
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.error,
                        "Error Accured!",
                      );
                    }
                  } catch (e) {
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.error,
                      "Error Accured!",
                    );
                  }
                }
              }
            }
          } else {
            SnackbarUtils.showSnackbar(
              context,
              Icons.paste,
              "Select the Folder or File to Copy and Paste",
            );
          }
        }
      },
      {
        "name": 'Copy',
        "onTap": () {
          if (checkFolder(currentFiles[_selectedindex].path)) {
            SnackbarUtils.showSnackbar(
              context,
              Icons.error,
              "You cannot A copy this Folder Or File",
            );
          } else {
            context
                .read<FileProvider>()
                .setSelectedPath(currentFiles[_selectedindex].path, true);
            SnackbarUtils.showSnackbar(
              context,
              Icons.copy,
              "File Or Folder Selected for Copying",
            );
          }
        },
      },
      {
        "name": 'Cut',
        "onTap": () {
          if (checkFolder(currentFiles[_selectedindex].path)) {
            SnackbarUtils.showSnackbar(
                context, Icons.error, "You cannot A Move this Folder Or File");
          } else {
            context.read<FileProvider>().setSelectedPath(
                  currentFiles[_selectedindex].path,
                  false,
                );
            SnackbarUtils.showSnackbar(
              context,
              Icons.copy,
              "File Or Folder Selected for Cuting",
            );
          }
        },
      },
      {
        "name": 'Delete',
        "onTap": () {
          if (checkFolder(currentFiles[_selectedindex].path)) {
            SnackbarUtils.showSnackbar(context, Icons.error,
                "You cannot A delete this Folder Or File");
          } else {
            currentFiles[_selectedindex] is File
                ? handleDelete(currentFiles[_selectedindex].path, true, context)
                : handleDelete(
                    currentFiles[_selectedindex].path, false, context);
          }
        },
      },
      {
        "name": 'Properties',
        "onTap": () {
          if (checkFolder(currentFiles[_selectedindex].path)) {
            SnackbarUtils.showSnackbar(context, Icons.error, "Access Denied!");
          } else {
            showDialog(
              context: context,
              builder: (context) =>
                  PropertiesWindow(path: currentFiles[_selectedindex].path),
            );
          }
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
                      : item['name'] == "rename"
                          ? Icons.edit_square
                          : item["name"] == 'Copy'
                              ? Icons.copy
                              : item["name"] == 'Delete'
                                  ? Icons.delete
                                  : item["name"] == 'Cut'
                                      ? Icons.cut
                                      : item["name"] == "Paste"
                                          ? Icons.paste
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
        } else {
          openFile(currentFiles[_selectedindex].path, context);
        }
        _lastClickTime = null; // Reset after detecting a double-click
        _selectedindex = -1;
      } else {
        setState(() {
          _selectedindex = index;
        });
        context.read<FileProvider>().setSelectedFile(true);
        context.read<FileProvider>().setSelectedIndex(index);
        if (event.buttons == kPrimaryButton) {
        } else if (event.buttons == kSecondaryButton) {
          showContextMenu(context, event.position);
        }
        _lastClickTime = now;
      }
    }

    return isGrid
        ? GridView.builder(
            itemCount: currentFiles.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio:
                  MediaQuery.of(context).size.width > 600 ? 1 : 0.8,
            ),
            itemBuilder: (context, index) {
              return Listener(
                onPointerDown: (PointerDownEvent event) =>
                    handleMouseClick(event, index),
                child: Card(
                  color: _selectedindex == index
                      ? AppTheme.accent.withValues(alpha: 0.8)
                      : null,
                  child: InkWell(
                    hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentFiles[index] is Directory
                              ? Icons.folder
                              : Icons.insert_drive_file,
                          size: 60,
                          color: _selectedindex==index?Colors.white:null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentFiles[index] is Directory
                              ? currentFiles[index]
                                  .path
                                  .split(Platform.pathSeparator)
                                  .last
                              : p.basenameWithoutExtension(
                                  currentFiles[index].path),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedindex==index?Colors.white:null,
                          ),
                        ),
                        currentFiles[index] is Directory
                            ? Text("Folder",
                            style: TextStyle(
                              color: _selectedindex==index?Colors.white:null,
                            ),)
                            : Text(
                                "${p.extension(currentFiles[index].path).split(".").last} File",
                                style: TextStyle(
                                  color: _selectedindex==index?Colors.white:null,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : ListView.builder(
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
                    leading: Icon(currentFiles[index] is Directory
                        ? Icons.folder
                        : Icons.insert_drive_file),
                    title: Text(
                      currentFiles[index] is Directory
                          ? currentFiles[index]
                              .path
                              .split(Platform.pathSeparator)
                              .last
                          : p.basenameWithoutExtension(
                              currentFiles[index].path),
                    ),
                    subtitle: currentFiles[index] is Directory
                        ? Text("Folder")
                        : Text(
                            "${p.extension(currentFiles[index].path).split(".").last} File",
                          ),
                    trailing: currentFiles[index] is Directory
                        ? null
                        : Text(
                            _formatSize(currentFiles[index].statSync().size)),
                    onTap: () {},
                  ),
                ),
              );
            },
          );
  }

  static String _formatSize(int size) {
    if (size < 1024) return '$size bytes';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1073741824) return '${(size / 1048576).toStringAsFixed(2)} MB';
    return '${(size / 1073741824).toStringAsFixed(2)} GB';
  }
}
