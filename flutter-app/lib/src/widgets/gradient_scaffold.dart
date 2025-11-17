import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  GradientScaffold({required this.child, this.colors = const [Color(0xff6a11cb), Color(0xff2575fc)]});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(child: child),
    );
  }
}
