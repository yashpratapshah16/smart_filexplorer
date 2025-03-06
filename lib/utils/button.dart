import 'package:flutter/material.dart';

class Button {
  Material actionButton(Function()? onTap, IconData icon,{bool disable=true}) {
    return Material(
      color: Colors.transparent,
      type: MaterialType.button,
      clipBehavior: Clip.antiAlias,
      borderOnForeground: true,
      elevation: 0,
      child: InkWell(
        hoverColor: Colors.grey,
        onTap:disable?onTap:null,
        child: Container(
          margin: EdgeInsets.all(2.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
