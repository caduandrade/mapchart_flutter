import 'package:flutter/material.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme._(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors})
      : this._color = color != null ? color : Color(0xFFE0E0E0),
        this.contourColor =
            contourColor != null ? contourColor : Color(0xFF9E9E9E),
        this.hoverContourColor = hoverContourColor,
        this.contourThickness = contourThickness != null ? contourThickness : 1,
        this._hoverColor = hoverColor,
        this._colors = colors,
        this._hoverColors = hoverColors;

  /// Creates a theme with default colors.
  factory MapChartTheme(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor}) {
    return MapChartTheme._(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor);
  }

  /// Creates a theme with colors by identifier.
  factory MapChartTheme.byId(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors}) {
    return MapChartTheme._(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        colors: colors,
        hoverColors: hoverColors);
  }

  final Color _color;
  final Color? contourColor;
  final Color? hoverContourColor;
  final double contourThickness;
  final Color? _hoverColor;
  final Map<dynamic, Color>? _colors;
  final Map<dynamic, Color>? _hoverColors;

  bool hasAnyHoverColor() {
    return hoverContourColor != null ||
        _hoverColor != null ||
        (_hoverColors != null && _hoverColors!.isNotEmpty);
  }

  Color getColor(MapFeature feature) {
    if (_colors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        _colors!.containsKey(feature.properties!.identifier)) {
      return _colors![feature.properties!.identifier]!;
    }
    return _color;
  }

  Color? getHoverColor(MapFeature feature) {
    if (_hoverColors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        _hoverColors!.containsKey(feature.properties!.identifier)) {
      return _hoverColors![feature.properties!.identifier]!;
    }
    return _hoverColor;
  }
}
