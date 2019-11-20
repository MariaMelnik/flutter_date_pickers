import 'package:flutter/widgets.dart';

typedef EventDecoration EventDecorationBuilder(DateTime date);

/// Class to store styles for event.
@immutable
class EventDecoration {
  final BoxDecoration boxDecoration;
  final TextStyle textStyle;

  const EventDecoration({this.boxDecoration, this.textStyle});
}