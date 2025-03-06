import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';

class FilePath extends StatefulWidget {
  const FilePath({super.key});
  @override
  State<FilePath> createState() => _FilePathState();
}

class _FilePathState extends State<FilePath> {
  @override
  Widget build(BuildContext context) {
    List<String> paths = context
        .read<FileProvider>()
        .filePath(context.watch<FileProvider>().currentPath);

    List<String> newParts = ["This PC"];
    for (var path in paths) {
        List<String> paths = path.split(Platform.pathSeparator);
        newParts.add(paths.last);
    }
    newParts.remove("");
    print(paths);

    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.sidebarColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Icon(Icons.computer),
              Text(":"),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newParts.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: context
                            .read<FileProvider>()
                            .listOnlyFolders(paths[index]),
                        builder: (context, snapshot) {
                          List<String> folders = [];

                          if (snapshot.hasData) {
                            folders = snapshot.data!;
                          }

                          return Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<FileProvider>()
                                        .loadFiles(paths[index]);
                                  },
                                  child: Text(newParts[index]),
                                ),
                                _buildFloatingExpansionButton(
                                  context,
                                  folders.isEmpty ? [] : folders,
                                  paths[index],
                                ),
                              ],
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingExpansionButton(
    BuildContext context,
    List<String> items,
    String path,
  ) {
    return PopupMenuButton<String>(
      tooltip: "",
      offset: Offset(0, 25), // Adjust the position of the popup
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<String>(
            value: item,
            child: ListTile(
              leading: Icon(Icons.folder),
              title: Text(
                item,
                style: TextStyle(fontSize: 14),
              ),
            ),
          );
        }).toList();
      },
      onSelected: (value) {
        context.read<FileProvider>().loadFiles(path + r"\" + value);
      },
      child: Container(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
      ),
    );
  }
}
