import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:smart_filexplorer/screens/sides/left_side.dart';
import 'package:smart_filexplorer/screens/sides/right_side.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';
import 'package:smart_filexplorer/utils/organizing.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: AppTheme.borderColor,
        width: 1,
        child: Row(
          children: const [LeftSide(), RightSide()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>showDialog(context: context, builder:(context)=>Organizing()),
        tooltip: "Organize",
        child: Icon(Icons.sort),
      ),
      floatingActionButtonLocation:FloatingActionButtonLocation.startFloat,
    );
  }
}
