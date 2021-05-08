import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';
import 'package:mapchart/src/data_source.dart';

class MapChartTheme {
  MapChartTheme(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      List<Color>? gradientColors})
      : this._color = color != null ? color : Color(0xFFE0E0E0),
        this.contourColor =
            contourColor != null ? contourColor : Color(0xFF9E9E9E),
        this.hoverContourColor = hoverContourColor,
        this.contourThickness = contourThickness != null ? contourThickness : 1,
        this._hoverColor = hoverColor;

  /// Creates a theme with colors by identifier.
  static MapChartTheme identifier(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors}) {
    return _MapChartThemeId(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        colors: colors,
        hoverColors: hoverColors);
  }

  /// Creates a theme with gradient colors.
  static MapChartTheme gradient(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required double minValue,
      required double maxValue,
      required String valueField,
      required List<Color> gradientColors}) {
    if (gradientColors.length < 2) {
      throw MapChartError('At least 2 colors are required for the gradient.');
    }
    return _MapChartThemeGradient(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        minValue: minValue,
        maxValue: maxValue,
        valueField: valueField,
        gradientColors: gradientColors);
  }

  final Color _color;
  final Color? contourColor;
  final Color? hoverContourColor;
  final double contourThickness;
  final Color? _hoverColor;

  bool hasAnyHoverColor() {
    return hoverContourColor != null || _hoverColor != null;
  }

  Color getColor(MapFeature feature) {
    return _color;
  }

  Color? getHoverColor(MapFeature feature) {
    return _hoverColor;
  }
}

class _MapChartThemeId extends MapChartTheme {
  _MapChartThemeId(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors})
      : this._colors = colors,
        this._hoverColors = hoverColors,
        super(
            color: color,
            contourColor: contourColor,
            hoverContourColor: hoverContourColor,
            contourThickness: contourThickness,
            hoverColor: hoverColor);

  final Map<dynamic, Color>? _colors;
  final Map<dynamic, Color>? _hoverColors;

  bool hasAnyHoverColor() {
    return (_hoverColors != null && _hoverColors!.isNotEmpty) ||
        super.hasAnyHoverColor();
  }

  @override
  Color getColor(MapFeature feature) {
    if (_colors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        _colors!.containsKey(feature.properties!.identifier)) {
      return _colors![feature.properties!.identifier]!;
    }
    return super.getColor(feature);
  }

  @override
  Color? getHoverColor(MapFeature feature) {
    if (_hoverColors != null &&
        feature.properties != null &&
        feature.properties!.identifier != null &&
        _hoverColors!.containsKey(feature.properties!.identifier)) {
      return _hoverColors![feature.properties!.identifier]!;
    }
    return super.getHoverColor(feature);
  }
}

class _MapChartThemeGradient extends MapChartTheme {
  _MapChartThemeGradient(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required this.minValue,
      required this.maxValue,
      required this.valueField,
      required this.gradientColors})
      : super(
            color: color,
            contourColor: contourColor,
            hoverContourColor: hoverContourColor,
            contourThickness: contourThickness,
            hoverColor: hoverColor);

  final double minValue;
  final double maxValue;
  final String valueField;
  final List<Color> gradientColors;

  @override
  Color getColor(MapFeature feature) {
    dynamic? value = feature.getPropertyValue(valueField);
    double? doubleValue;
    if (value is int) {
      doubleValue = value.toDouble();
    } else if (value is double) {
      doubleValue = value;
    }

    return super.getColor(feature);
  }

  @override
  Color? getHoverColor(MapFeature feature) {
    return super.getHoverColor(feature);
  }
}
