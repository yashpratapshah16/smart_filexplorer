import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:smart_filexplorer/components/sidebar.dart';
import 'package:smart_filexplorer/providers/file_provider.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/button.dart';
import 'package:provider/provider.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    Button button = Button();
    return SizedBox(
      width: 200,
      child: Container(
        color: AppTheme.sidebarColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 3),
                child: Row(
                  spacing: 10,
                  children: [
                    button.actionButton(
                      () {
                        context.read<FileProvider>().goBack();
                      },
                      Icons.arrow_back,
                      "Backward",
                    ),
                    button.actionButton(
                      () {
                        context.read<FileProvider>().goFront();
                       },
                      Icons.arrow_forward,
                      "Forward"
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Divider(),
                  Expanded(
                    child: SideBar()
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
