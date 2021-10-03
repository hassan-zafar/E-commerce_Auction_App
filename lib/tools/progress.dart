import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

bouncingGridProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: LoadingBouncingGrid.circle(
      backgroundColor: Colors.black38,
      size: 30.0,
    ),
  );
}

linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
