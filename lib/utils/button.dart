import 'package:flutter/material.dart';

class Button {
  Material actionButton(
    Function()? onTap,
    IconData icon,
    String message, {
    bool disable = false,
    Color hoverColor = Colors.grey,
    Color color = Colors.white,
    Color bgColor= Colors.transparent,
  }) {
    return Material(
      color: Colors.transparent,
      type: MaterialType.button,
      clipBehavior: Clip.antiAlias,
      borderOnForeground: true,
      elevation: 0,
      child: InkWell(
        hoverColor: hoverColor,
        onTap: disable ? null : onTap,
        child: Container(
          color: bgColor,
          margin: EdgeInsets.all(2.0),
          child: Tooltip(
            message: disable ? "" : message,
            child: Icon(
              icon,
              color: disable ? Colors.grey : color,
            ),
          ),
        ),
      ),
    );
  }
}
