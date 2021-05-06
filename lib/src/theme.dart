import 'package:flutter/material.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme(
      {this.color = const Color(0xFFE0E0E0), //grey 300
      this.contourColor = const Color(0xFF9E9E9E), // grey 500
      this.hoverContourColor,
      this.contourThickness = 1,
      this.highlightColor = const Color(0xFF616161), // grey 700
      this.colors,
      this.highlightColors});

  final Color color;
  final Color? contourColor;
  final Color? hoverContourColor;
  final double contourThickness;
  final Color? highlightColor;
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

  Color? getHighlightColor(MapFeature feature) {
    if (highlightColors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        highlightColors!.containsKey(feature.properties!.identifier)) {
      return highlightColors![feature.properties!.identifier]!;
    }
    return highlightColor;
  }
}
