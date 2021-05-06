import 'package:flutter/material.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme._(
      {required this.color,
      required this.contourColor,
      required this.contourThickness,
      required this.highlightColor,
      this.colors,
      this.highlightColors});

  factory MapChartTheme(
      {Color? color,
      Color? contourColor,
      double contourThickness = 1,
      Color? highlightColor,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? highlightColors}) {
    return MapChartTheme._(
        color: color != null ? color : Colors.grey[300]!,
        contourColor: contourColor != null ? contourColor : Colors.grey[500]!,
        contourThickness: contourThickness,
        highlightColor:
            highlightColor != null ? highlightColor : Colors.grey[700]!,
        colors: colors,
        highlightColors: highlightColors);
  }

  final Color color;
  final Color contourColor;
  final double contourThickness;
  final Color highlightColor;
  final Map<dynamic, Color>? colors;
  final Map<dynamic, Color>? highlightColors;

  Color getColor(MapFeature feature) {
    if (colors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        colors!.containsKey(feature.properties!.identifier)) {
      return colors![feature.properties!.identifier]!;
    }
    return color;
  }

  Color getHighlightColor(MapFeature feature) {
    if (highlightColors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        highlightColors!.containsKey(feature.properties!.identifier)) {
      return highlightColors![feature.properties!.identifier]!;
    }
    return highlightColor;
  }
}
