import 'package:flutter/material.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme(
      {this.color = const Color(0xFFE0E0E0), //grey 300
      this.contourColor = const Color(0xFF9E9E9E), // grey 500
      this.hoverContourColor,
      this.contourThickness = 1,
      this.hoverColor,
      this.colors,
      this.hoverColors});

  final Color color;
  final Color? contourColor;
  final Color? hoverContourColor;
  final double contourThickness;
  final Color? hoverColor;
  final Map<dynamic, Color>? colors;
  final Map<dynamic, Color>? hoverColors;

  bool isHoverEnabled() {
    return hoverContourColor != null ||
        hoverColor != null ||
        (hoverColors != null && hoverColors!.isNotEmpty);
  }

  Color getColor(MapFeature feature) {
    if (colors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        colors!.containsKey(feature.properties!.identifier)) {
      return colors![feature.properties!.identifier]!;
    }
    return color;
  }

  Color? getHoverColor(MapFeature feature) {
    if (hoverColors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        hoverColors!.containsKey(feature.properties!.identifier)) {
      return hoverColors![feature.properties!.identifier]!;
    }
    return hoverColor;
  }
}
