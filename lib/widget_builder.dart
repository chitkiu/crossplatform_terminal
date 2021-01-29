import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'color_constants.dart';

class MainWidgetBuilder {

  static AppBar appBar(String toolbarText, {bool centerTitle = true, Widget leading = null}) {
    return AppBar(
      title: Text(
        toolbarText,
        style: TextStyle(color: ColorConstant.appBarText),
      ),
      backgroundColor: ColorConstant.appBarBackground,
      leading: leading,
      centerTitle: centerTitle,
    );
  }

  static Widget textInput(String hint, TextEditingController controller, {bool obscureText = false, bool autofocus = false, VoidCallback onEditingComplete = null, TextInputAction textInputAction = null, int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: ColorConstant.mainText),
      autofocus: autofocus,
      obscureText: obscureText,
      onEditingComplete: onEditingComplete,
      textInputAction: textInputAction,
      maxLines: maxLines,
      cursorColor: ColorConstant.mainText,
      decoration: new InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(127, 255, 255, 255)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(127, 255, 255, 255)),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        labelStyle: TextStyle(color: Color.fromARGB(178, 255, 255, 255)),
        labelText: hint,
      ),
    );
  }

  static Widget alertDialog(Widget content, {String title = "", List<Widget> actions}) {
    Widget titleWidget = null;
    if(title.isNotEmpty) {
      titleWidget = text(title);
    }

    ///Later added different dialog for MacOS and iOS
    // if(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isAndroid) {
    return Theme(
      data: ThemeData(dialogBackgroundColor: ColorConstant.appBarBackground),
      child: AlertDialog(
        title: titleWidget,
        content: content,
        actions: actions,
      ),
    );
    /*} else {
      return CupertinoAlertDialog(
          title: titleWidget,
          content: content,
          actions: actions,
        );
    }*/
  }

  static Widget selectableText(String data) {
    return new SelectableText(
        data,
        toolbarOptions: ToolbarOptions(
            copy: true,
            selectAll: true,
            cut: false,
            paste: false
        ),
        showCursor: false,
        style: TextStyle(color: ColorConstant.mainText)
    );
  }

  static Widget flatButton(String data, VoidCallback onPressed) {
    return new FlatButton(
      child: Text(data),
      textColor: ColorConstant.mainText,
      onPressed: onPressed,
    );
  }

  static Widget textWithSelectableText(String textString, String selectableTextString) {
    return Row(
      children: [
        text(textString),
        selectableText(selectableTextString)
      ],
    );
  }

  static Widget button(String buttonText, VoidCallback clickListener) {
    return RaisedButton(
      onPressed: clickListener,
      color: ColorConstant.mainButton,
      hoverColor: ColorConstant.mainHover,
      child: text(buttonText),
    );
  }

  static Widget text(String text, {double topPadding = 0.0, double bottomPadding = 0.0, double leftPadding = 0.0, double rightPadding = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(
          left: leftPadding,
          right: rightPadding,
          top: topPadding,
          bottom: bottomPadding
      ),
      child: Text(
        text,
        style: TextStyle(
            color: ColorConstant.mainText
        ),
      ),
    );
  }
}
