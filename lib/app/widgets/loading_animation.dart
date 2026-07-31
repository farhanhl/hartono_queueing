import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimationWidgets {
  static Widget loadingAnimation({
    required double size,
    required Color color,
  }) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: color,
        size: size,
      ),
    );
  }
}
