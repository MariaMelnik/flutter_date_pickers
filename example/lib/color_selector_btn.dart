import 'package:flutter/material.dart';


// round colored button with title to select some style color
class ColorSelectorBtn extends StatelessWidget{
  // title near color button
  final String title;

  final Color color;

  // onTap callback
  final Function showDialogFunction;

  const ColorSelectorBtn({
    Key key,
    @required this.title,
    @required this.color,
    @required this.showDialogFunction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: showDialogFunction,
            child: Container(
              height: 24.0,
              width: 24.0,
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