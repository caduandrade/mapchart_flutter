import 'package:flutter/material.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme._(
      {required this.color,
      required this.contourColor,
      required this.drawContour,
      required this.highlightColor,
      this.colors});

  factory MapChartTheme(
      {Color? color,
      Color? contourColor,
      bool drawContour = true,
      Color? highlightColor,
      Map<dynamic, Color>? colors}) {
    return MapChartTheme._(
        color: color != null ? color : Colors.grey[300]!,
        contourColor: contourColor != null ? contourColor : Colors.grey[500]!,
        drawContour: drawContour,
        highlightColor:
            highlightColor != null ? highlightColor : Colors.grey[700]!,
        colors: colors);
  }

  final Color color;
  final Color contourColor;
  final bool drawContour;
  final Color highlightColor;
  final Map<dynamic, Color>? colors;

  Color getColor(MapFeature feature) {
    if (colors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        colors!.containsKey(feature.properties!.identifier)) {
      return colors![feature.properties!.identifier]!;
    }
    return color;
  }
}
