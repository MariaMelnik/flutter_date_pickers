import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Icon button widget built defferent depends on MaterialApp or CupertinoApp ancestor.
class IconBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String tooltip;

  const IconBtn({Key key, this.icon, this.onTap, this.tooltip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMaterial =  Material.of(context) != null;

    return isMaterial
      ? _materialBtn()
      : _cupertinoBtn();
  }

  Widget _cupertinoBtn() {
    return CupertinoButton(
      padding: const EdgeInsets.all(0.0),
      child: icon,
      onPressed: onTap,
    );
  }

  Widget _materialBtn() {
    return IconButton(
       icon: icon,
       tooltip: tooltip ?? "",
       onPressed: onTap,
    );
  }
}
