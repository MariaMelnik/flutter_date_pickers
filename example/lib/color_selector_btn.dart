import 'package:flutter/material.dart';

// default with and height for the button container
const double _kBtnSize = 24.0;

// round colored button with title to select some style color
class ColorSelectorBtn extends StatelessWidget {
  // title near color button
  final String title;

  final Color color;

  // onTap callback
  final Function showDialogFunction;

  final double colorBtnSize;

  const ColorSelectorBtn(
      {Key key,
      @required this.title,
      @required this.color,
      @required this.showDialogFunction,
      this.colorBtnSize = _kBtnSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: showDialogFunction,
            child: Container(
              height: colorBtnSize,
              width: colorBtnSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Expanded(
              child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }
}
