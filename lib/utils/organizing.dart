// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/operations.dart';
import 'package:smart_filexplorer/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool checkFolder(String path) {
  if (path.contains(r"C:\Windows")) {
    return true;
  } else if (path == "C:") {
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

class Organizing extends StatefulWidget {
  const Organizing({super.key});

  @override
  State<Organizing> createState() => _OrganizingState();
}

class _OrganizingState extends State<Organizing> {
  bool _isOrganizing = false;
  bool _isName = false;

  @override
  Widget build(BuildContext context) {
    String currentPath = context.read<FileProvider>().currentPath;
    TextEditingController nameController = TextEditingController();
    if (checkFolder(currentPath)) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Cannot Orgnaize This Directory!"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      );
    }

    void handle(String name, BuildContext context) {
      if (name.isEmpty) {
        SnackbarUtils.showSnackbar(context, Icons.error, "Field is Empty");
      } else {
        _organizeByName(context, name);
      }
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: _isOrganizing
          ? Text("Organizing...")
          : _isName
              ? Text("Organizing by Name")
              : Text("Organize the Files And Folder"),
      content: SingleChildScrollView(
        child: Column(
          children: _isOrganizing
              ? [
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                  ),
                ]
              : _isName
                  ? [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter the Similar Name the File Contents",
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
                        onSubmitted: (name) => handle(name, context),
                      )
                    ]
                  : [
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.extension),
                          title: Text("By Extension"),
                          onTap: () {
                            _organizeByExtensionORDate(
                              context,
                              extension: true,
                            );
                          },
                        ),
                      ),
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.date_range),
                          title: Text("By Date(Date-Month-Year)"),
                          onTap: () {
                            _organizeByExtensionORDate(
                              context,
                              date: true,
                              dateFormat: "dd MMM yyyy",
                            );
                          },
                        ),
                      ),
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.date_range),
                          title: Text("By Date(Month-Year)"),
                          onTap: () {
                            _organizeByExtensionORDate(
                              context,
                              date: true,
                              dateFormat: "MMM yyyy",
                            );
                          },
                        ),
                      ),
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.folder_copy_outlined),
                          title: Text(
                              "By Date And Extensions(Month-Year/Extensions)"),
                          onTap: () {
                            _organizeByExtensionORDate(
                              context,
                              date: true,
                              dateFormat: "MMM yyyy",
                              extension: true,
                            );
                          },
                        ),
                      ),
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.folder_copy_rounded),
                          title: Text("By Date(Date-Month-Year)/Extensions"),
                          onTap: () {
                            _organizeByExtensionORDate(
                              context,
                              date: true,
                              dateFormat: "dd MMM yyyy",
                              extension: true,
                            );
                          },
                        ),
                      ),
                      Material(
                        child: ListTile(
                          hoverColor: AppTheme.accent.withValues(alpha: 0.5),
                          leading: Icon(Icons.abc),
                          title: Text("By Name"),
                          onTap: () {
                            setState(() {
                              _isName = true;
                            });
                          },
                        ),
                      ),
                    ],
        ),
      ),
      actions: [
        _isName
            ? TextButton(
                onPressed: () => handle(nameController.text, context),
                child: Text("Submit"))
            : Text(""),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Close")),
      ],
    );
  }

  void _organizeByExtensionORDate(BuildContext context,
      {bool date = false,
      String dateFormat = "",
      bool extension = false}) async {
    setState(() {
      _isOrganizing = true;
    });
    String srcPath = "";
    String destPath = "";
    final currentFiles = context.read<FileProvider>().files;
    bool dir = false;

    if (date && extension) {
      for (final file in currentFiles) {
        final parent = file.parent.path;
        String date = _returnDate(file.statSync().modified, dateFormat);
        srcPath = file.path;
        if (file is Directory) {
          dir = false;
          destPath = p.joinAll(
              [parent, date, "Remaining Folders", p.basename(file.path)]);
        } else {
          dir = true;
          destPath = p.joinAll([
            parent,
            date,
            p.extension(file.path).split(".").last,
          ]);
          final tempDir = Directory(destPath);
          await tempDir.create(recursive: true);
          destPath += "${Platform.pathSeparator}${p.basename(file.path)}";
        }
        bool succees = await Operations.moveEntity(srcPath, destPath, dir);
        if (!succees) {
          SnackbarUtils.showSnackbar(context, Icons.error, "Error Accured!");
          break;
        }
      }
    } else if (extension) {
      for (final file in currentFiles) {
        final parent = file.parent.path;
        srcPath = file.path;
        if (file is Directory) {
          dir = false;
          destPath =
              p.joinAll([parent, "Remaining Folders", p.basename(file.path)]);
        } else {
          dir = true;
          destPath = p.joinAll([
            parent,
            p.extension(file.path).split(".").last,
          ]);
          final tempDir = Directory(destPath);
          await tempDir.create(recursive: true);
          destPath += "${Platform.pathSeparator}${p.basename(file.path)}";
        }
        bool succees = await Operations.moveEntity(srcPath, destPath, dir);
        if (!succees) {
          SnackbarUtils.showSnackbar(context, Icons.error, "Error Accured!");
          break;
        }
      }
    } else {
      for (final file in currentFiles) {
        final parent = file.parent.path;
        String date = _returnDate(file.statSync().modified, dateFormat);
        srcPath = file.path;
        if (file is Directory) {
          dir = false;
          destPath = p.joinAll(
              [parent, date, "Remaining Folders", p.basename(file.path)]);
        } else {
          dir = true;
          destPath = p.joinAll([
            parent,
            date,
          ]);
          final tempDir = Directory(destPath);
          await tempDir.create(recursive: true);
          destPath += "${Platform.pathSeparator}${p.basename(file.path)}";
        }
        bool succees = await Operations.moveEntity(srcPath, destPath, dir);
        if (!succees) {
          SnackbarUtils.showSnackbar(context, Icons.error, "Error Accured!");
          break;
        }
      }
    }
    SnackbarUtils.showSnackbar(
        context, Icons.done_all, "Done With Organizing The Files and Folders");
    await context
        .read<FileProvider>()
        .loadFiles(context.read<FileProvider>().currentPath);
    setState(() {
      _isOrganizing = false;
    });
    Navigator.pop(context);
  }

  void _organizeByName(BuildContext context, String name) async {
    setState(() {
      _isName = false;
      _isOrganizing = true;
    });
    final currentFiles = context.read<FileProvider>().files;
    int count = 0;
    for (int i = 0; i < currentFiles.length; i++) {
      if (currentFiles[i] is File) {
        String curname = p.basenameWithoutExtension(currentFiles[i].path);
        final temp = curname.split(" ");
        final index = temp.indexWhere((val) => val.contains(name));
        if (index != -1) {
          String currentPath =
              p.joinAll([currentFiles[i].parent.path, temp[index]]);
          try {
            final dir = Directory(currentPath);
            await dir.create(recursive: true);
            currentPath +=
                "${Platform.pathSeparator}${p.basename(currentFiles[i].path)}";
            final srcfile = File(currentFiles[i].path);
            await srcfile.copy(currentPath);
            await srcfile.delete();
            count++;
          } catch (e) {
            count = 0;
            break;
          }
        }
      }
    }
    if (count == 0) {
      SnackbarUtils.showSnackbar(
          context, Icons.error, "The No Similar Names File");
    } else {
      SnackbarUtils.showSnackbar(
          context, Icons.done_all, "Done With Organizing The Files");
    }
    await context
        .read<FileProvider>()
        .loadFiles(context.read<FileProvider>().currentPath);
    setState(() {
      _isOrganizing = false;
    });
    Navigator.pop(context);
  }

  String _returnDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
}
