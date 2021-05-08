import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';
import 'package:mapchart/src/data_source.dart';

/// Rule to obtain a color of a feature.
typedef ColorRule = Color? Function(MapFeature feature);

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

  /// Creates a theme with colors by property value.
  static MapChartTheme value(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required String key,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors}) {
    return _MapChartThemeValue(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        key: key,
        colors: colors,
        hoverColors: hoverColors);
  }

  /// Creates a theme with colors by rule.
  /// The feature color is obtained from the first rule that returns
  /// a non-null color.
  /// If all rules return a null color, the default color is used.
  static MapChartTheme rule(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required List<ColorRule> colorRules,
      List<ColorRule>? hoverColorRules}) {
    return _MapChartThemeRule(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        colorRules: colorRules,
        hoverColorRules: hoverColorRules);
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

class _MapChartThemeValue extends MapChartTheme {
  _MapChartThemeValue(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required this.key,
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

  final String key;
  final Map<dynamic, Color>? _colors;
  final Map<dynamic, Color>? _hoverColors;

  bool hasAnyHoverColor() {
    return (_hoverColors != null && _hoverColors!.isNotEmpty) ||
        super.hasAnyHoverColor();
  }

  @override
  Color getColor(MapFeature feature) {
    if (_colors != null) {
      dynamic? value = feature.getValue(key);
      if (value != null && _colors!.containsKey(value)) {
        return _colors![value]!;
      }
    }
    return super.getColor(feature);
  }

  @override
  Color? getHoverColor(MapFeature feature) {
    if (_hoverColors != null) {
      dynamic? value = feature.getValue(key);
      if (value != null && _hoverColors!.containsKey(value)) {
        return _hoverColors![value]!;
      }
    }
    return super.getHoverColor(feature);
  }
}

class _MapChartThemeRule extends MapChartTheme {
  _MapChartThemeRule(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      required List<ColorRule> colorRules,
      List<ColorRule>? hoverColorRules})
      : this._colorRules = colorRules,
        this._hoverColorRules = hoverColorRules,
        super(
            color: color,
            contourColor: contourColor,
            hoverContourColor: hoverContourColor,
            contourThickness: contourThickness,
            hoverColor: hoverColor);

  final List<ColorRule> _colorRules;
  final List<ColorRule>? _hoverColorRules;

  @override
  bool hasAnyHoverColor() {
    //It is not possible to know in advance, it depends on the rule.
    return true;
  }

  @override
  Color getColor(MapFeature feature) {
    Color? color;
    for (ColorRule rule in _colorRules) {
      color = rule(feature);
      if (color != null) {
        break;
      }
    }
    return color != null ? color : super.getColor(feature);
  }

  @override
  Color? getHoverColor(MapFeature feature) {
    Color? color;
    if (_hoverColorRules != null) {
      for (ColorRule rule in _colorRules) {
        color = rule(feature);
        if (color != null) {
          break;
        }
      }
    }
    return color != null ? color : super.getHoverColor(feature);
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
    dynamic? value = feature.getValue(valueField);
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
