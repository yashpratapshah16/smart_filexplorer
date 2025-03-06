import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final userProfile = Platform.environment["USERPROFILE"];
  int _selectedindex = -1;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _list(
          Icons.desktop_windows,
          Color(0xFF1892CB),
          "Desktop",
          () => context.read<FileProvider>().loadFiles("$userProfile/Desktop"),
          0,
        ),
        _list(
          Icons.download,
          Color(0xFF20A286),
          "Downloads",
          () =>
              context.read<FileProvider>().loadFiles("$userProfile/Downloads"),
          1,
        ),
        _list(
          Icons.edit_document,
          Color(0xFF768FA9),
          "Documents",
          () =>
              context.read<FileProvider>().loadFiles("$userProfile/Documents"),
          2,
        ),
        _list(
          Icons.library_music,
          Color(0xFFE0806A),
          "Music",
          () => context.read<FileProvider>().loadFiles("$userProfile/Music"),
          3,
        ),
        _list(
          Icons.image,
          Color(0xFF148DD7),
          "Pictures",
          () => context.read<FileProvider>().loadFiles("$userProfile/Pictures"),
          4,
        ),
        _list(
          Icons.video_collection,
          Color(0xFFA160EF),
          "Videos",
          () => context.read<FileProvider>().loadFiles("$userProfile/Videos"),
          5,
        ),
      ],
    );
  }

  Material _list(IconData icon, Color iconColor, String text, Function()? onTap,
      int index) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: index == _selectedindex,
        selectedTileColor: AppTheme.accent.withValues(alpha: 0.5),
        hoverColor: AppTheme.accent.withValues(alpha: 0.4),
        leading: Icon(
          icon,
          color: iconColor,
        ),
        title: Text(
          text,
          style: AppTheme.sidebarText,
        ),
        onTap: () {
          setState(() {
            _selectedindex = index;
          });
          onTap!();
        },
      ),
    );
  }
}
