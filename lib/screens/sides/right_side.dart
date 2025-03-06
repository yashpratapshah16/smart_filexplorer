import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:smart_filexplorer/components/file_explorer.dart';
import 'package:smart_filexplorer/components/file_path.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';

class RightSide extends StatelessWidget {
  const RightSide({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundStartColor,
                AppTheme.backgroundEndColor
              ],
              stops: [
                0.0,
                1.0
              ]),
        ),
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const WindowButtons()
                ],
              ),
            ),
            Expanded(
                child: Column(
              children: [
                Divider(),
                FilePath(),
                Divider(),
                Expanded(
                  child: FileExplorer(),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
  iconNormal: Colors.grey,
  mouseOver: AppTheme.accent,
  mouseDown: AppTheme.sidebarColor,
  iconMouseOver: AppTheme.sidebarColor,
  iconMouseDown: AppTheme.accent,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.grey,
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
