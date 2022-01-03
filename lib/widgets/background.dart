import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final double height;
  final Color? shapeColor;

  AppBackground({
    Key? key,
    this.height = 200.0,
    this.shapeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1.0,
          child: ClipPath(
            clipper: CustomShape(),
            child: Container(
              height: height,
              color: (shapeColor != null)
                  ? shapeColor
                  : Theme.of(context).primaryColor,
            ),
          ),
        ),
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShape(),
            child: Container(
              height: height + 30,
              color: (shapeColor != null)
                  ? shapeColor
                  : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 80);
    path.quadraticBezierTo(width / 2, height, width, height - 80);
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
