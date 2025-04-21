// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/button.dart';
import 'package:smart_filexplorer/utils/operations.dart';
import 'package:smart_filexplorer/utils/properties.dart';
import 'package:smart_filexplorer/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

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

class Operators extends StatefulWidget {
  const Operators({super.key});

  @override
  State<Operators> createState() => _OperatorsState();
}

class _OperatorsState extends State<Operators> {
  List<String> items = ["New Folder", "New File"];
  Button button = Button();
  @override
  Widget build(BuildContext context) {
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

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        spacing: 20,
        children: [
          PopupMenuButton(
            tooltip: "",
            offset: Offset(50, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (context) {
              return items.map((item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: ListTile(
                    leading: item.contains("File")
                        ? Icon(Icons.insert_drive_file)
                        : Icon(Icons.folder),
                    title: Text(
                      item,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(
                  Icons.add_circle_rounded,
                ),
                Text(
                  "New",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            onSelected: (value) => _create(value),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              button.actionButton(
                () {
                  int index = context.read<FileProvider>().selectedIndex;
                  if (index != -1) {
                    List<FileSystemEntity> currentFiles =
                        context.read<FileProvider>().files;
                    if (checkFolder(currentFiles[index].path)) {
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.error,
                        "You cannot A copy this Folder Or File",
                      );
                    } else {
                      context
                          .read<FileProvider>()
                          .setSelectedPath(currentFiles[index].path, true);
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.copy,
                        "File Or Folder Selected for Copying",
                      );
                    }
                  }
                },
                Icons.copy,
                "Copy",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                disable:
                    context.watch<FileProvider>().selectedFile ? false : true,
              ),
              button.actionButton(
                () {
                  int index = context.read<FileProvider>().selectedIndex;
                  final currentFiles = context.read<FileProvider>().files;
                  if (checkFolder(currentFiles[index].path)) {
                    SnackbarUtils.showSnackbar(context, Icons.error,
                        "You cannot A Move this Folder Or File");
                  } else {
                    context.read<FileProvider>().setSelectedPath(
                          currentFiles[index].path,
                          false,
                        );
                    SnackbarUtils.showSnackbar(
                      context,
                      Icons.copy,
                      "File Or Folder Selected for Cuting",
                    );
                  }
                },
                Icons.cut,
                "Cut",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                disable:
                    context.watch<FileProvider>().selectedFile ? false : true,
              ),
              button.actionButton(
                () async {
                  final currentFiles = context.read<FileProvider>().files;
                  int selectedindex =
                      context.read<FileProvider>().selectedIndex;
                  if (checkFolder(currentFiles[selectedindex].path)) {
                    SnackbarUtils.showSnackbar(context, Icons.error,
                        "You cannot A Rename this Folder Or File");
                  } else {
                    String name = currentFiles[selectedindex]
                        .path
                        .split(Platform.pathSeparator)
                        .last;
                    TextEditingController nameController =
                        TextEditingController();
                    Future<void> handle() async {
                      if (currentFiles[selectedindex] is File) {
                        await Operations.renameEntity(
                          currentFiles[selectedindex].parent.path,
                          name,
                          nameController.text,
                          true,
                          context,
                        );
                        SnackbarUtils.showSnackbar(
                          context,
                          Icons.edit_square,
                          "File Renamed.",
                        );
                      } else {
                        await Operations.renameEntity(
                          currentFiles[selectedindex].parent.path,
                          name,
                          nameController.text,
                          false,
                          context,
                        );
                        SnackbarUtils.showSnackbar(
                          context,
                          Icons.edit_square,
                          "Folder Renamed.",
                        );
                      }
                      context
                          .read<FileProvider>()
                          .loadFiles(currentFiles[selectedindex].parent.path);
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
                Icons.edit_square,
                "Rename",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                disable:
                    context.watch<FileProvider>().selectedFile ? false : true,
              ),
              button.actionButton(
                () async {
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
                            final success = await Operations.moveEntity(
                                path, destPath, false);
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
                            final success = await Operations.moveEntity(
                                path, destPath, true);
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
                },
                Icons.paste,
                "Paste",
                hoverColor: AppTheme.accent,
                color: Colors.black,
              ),
              button.actionButton(
                () {
                  int index = context.read<FileProvider>().selectedIndex;
                  if (index != -1) {
                    List<FileSystemEntity> currentFiles =
                        context.read<FileProvider>().files;
                    if (checkFolder(currentFiles[index].path)) {
                      SnackbarUtils.showSnackbar(
                        context,
                        Icons.error,
                        "You cannot A delete this Folder Or File",
                      );
                    } else {
                      currentFiles[index] is Directory
                          ? handleDelete(
                              currentFiles[index].path, false, context)
                          : handleDelete(
                              currentFiles[index].path, true, context);
                    }
                  }
                },
                Icons.delete,
                "Delete",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                disable:
                    context.watch<FileProvider>().selectedFile ? false : true,
              ),
              button.actionButton(
                () {
                  final currentFiles = context.read<FileProvider>().files;
                  int selectedIndex =
                      context.read<FileProvider>().selectedIndex;

                  if (checkFolder(currentFiles[selectedIndex].path)) {
                    SnackbarUtils.showSnackbar(
                        context, Icons.error, "Access Denied!");
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => PropertiesWindow(
                          path: currentFiles[selectedIndex].path),
                    );
                  }
                },
                Icons.info,
                "Properties",
                hoverColor: AppTheme.accent,
                color: Colors.black,
                disable:
                    context.watch<FileProvider>().selectedFile ? false : true,
              ),
              button.actionButton(
                () => context.read<FileProvider>().setView(!isGrid),
                isGrid ? Icons.grid_on : Icons.list,
                "View",
                hoverColor: AppTheme.accent,
                color: Colors.black,
              )
            ],
          ),
          button.actionButton(
            () => context.read<FileProvider>().setSearch(true),
            Icons.search,
            "Search",
            hoverColor: AppTheme.accent,
            color: Colors.black,
          )
        ],
      ),
    );
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

  Future<void> _create(String value) async {
    TextEditingController nameController = TextEditingController();
    Future<void> handle() async {
      String name = nameController.text;
      if (name.isNotEmpty) {
        if (RegExp(r'^[^\\/:*?".<>|]+$').hasMatch(name) &&
            name.trim().isNotEmpty) {
          String currentPath = context.read<FileProvider>().currentPath;
          String path =
              "$currentPath${Platform.pathSeparator}$name${value.contains("File") ? ".txt" : ""}";

          if (value.contains("File")) {
            if (await Operations.createFile(path)) {
              SnackbarUtils.showSnackbar(
                context,
                Icons.done,
                "File Created.",
              );

              context.read<FileProvider>().loadFiles(currentPath);
            } else {
              SnackbarUtils.showSnackbar(
                context,
                Icons.error,
                "Failed!",
              );
            }
          } else {
            if (await Operations.createDirectory(path)) {
              SnackbarUtils.showSnackbar(
                context,
                Icons.done,
                "Folder Created.",
              );

              context.read<FileProvider>().loadFiles(currentPath);
            } else {
              SnackbarUtils.showSnackbar(
                context,
                Icons.error,
                "Failed!",
              );
            }
          }
          Navigator.pop(context);
        } else {
          SnackbarUtils.showSnackbar(
            context,
            Icons.error,
            "Invalid Name!",
          );
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(value),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter the Name of $value",
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
            child: Text("Create"),
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
}
