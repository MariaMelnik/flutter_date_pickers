import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color selectedColor;

  const ColorPickerDialog({Key key, this.selectedColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  ColorSwatch _mainColor;

  @override
  void initState() {
    super.initState();

    _mainColor = !materialColors.contains(widget.selectedColor)
        ? Colors
            .blue // pre-select color if [widget.selectedColor] is not in main material colors palette
        : widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(6.0),
      title: Text("Color picker"),
      content: MaterialColorPicker(
        selectedColor: _mainColor,
        allowShades: false,
        onMainColorChange: (color) => setState(() => _mainColor = color),
      ),
      actions: [
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        FlatButton(
          child: Text('SUBMIT'),
          onPressed: () {
            Navigator.of(context).pop(_mainColor);
          },
        ),
      ],
    );
  }
}
