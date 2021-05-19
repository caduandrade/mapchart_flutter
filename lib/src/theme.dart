import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';
import 'package:mapchart/src/data_source.dart';

/// Rule to obtain a color of a feature.
typedef ColorRule = Color? Function(MapFeature feature);

typedef LabelStyleBuilder = TextStyle Function(
    MapFeature feature, Color featureColor, Color labelColor, bool hover);

class MapChartTheme {
  /// Theme for [MapChart]
  /// The default [hoverColor] value is null.
  /// The default [contourThickness] value is 1.
  MapChartTheme(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      LabelStyleBuilder? labelStyleBuilder})
      : this._color = color != null ? color : Color(0xFFE0E0E0),
        this.contourColor =
            contourColor != null ? contourColor : Color(0xFF9E9E9E),
        this.hoverContourColor = hoverContourColor,
        this.contourThickness = contourThickness != null ? contourThickness : 1,
        this._hoverColor = hoverColor,
        this.labelStyleBuilder = labelStyleBuilder;

  /// Creates a theme with colors by property value.
  static MapChartTheme value(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      LabelStyleBuilder? labelStyleBuilder,
      required String key,
      Map<dynamic, Color>? colors,
      Map<dynamic, Color>? hoverColors}) {
    return _MapChartThemeValue(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        labelStyleBuilder: labelStyleBuilder,
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
      LabelStyleBuilder? labelStyleBuilder,
      required List<ColorRule> colorRules,
      List<ColorRule>? hoverColorRules}) {
    return _MapChartThemeRule(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        labelStyleBuilder: labelStyleBuilder,
        colorRules: colorRules,
        hoverColorRules: hoverColorRules);
  }

  /// Creates a theme with gradient colors.
  /// The gradient is created given the colors and limit values of the
  /// chosen property.
  /// The property must have numeric values.
  /// If the [min] is set, all smaller values will be displayed with the first
  /// gradient color.
  /// If the [max] is set, all larger values will be displayed with the last
  /// gradient color.
  static MapChartTheme gradient(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      LabelStyleBuilder? labelStyleBuilder,
      MapChartDataSource? dataSource,
      double? min,
      double? max,
      required String key,
      required List<Color> colors}) {
    if (colors.length < 2) {
      throw MapChartError('At least 2 colors are required for the gradient.');
    }

    PropertyLimits? propertyLimits = dataSource?.getPropertyLimits(key);
    if (propertyLimits != null) {
      if (min == null) {
        min = propertyLimits.min;
      }
      if (max == null) {
        max = propertyLimits.max;
      }
    }
    if (min == null) {
      throw MapChartError('Min value has not been set');
    }
    if (max == null) {
      throw MapChartError('Max value has not been set');
    }

    return _MapChartThemeGradient(
        color: color,
        contourColor: contourColor,
        hoverContourColor: hoverContourColor,
        contourThickness: contourThickness,
        hoverColor: hoverColor,
        labelStyleBuilder: labelStyleBuilder,
        min: min,
        max: max,
        key: key,
        colors: colors);
  }

  final Color _color;
  final Color? contourColor;
  final Color? hoverContourColor;
  final double contourThickness;
  final Color? _hoverColor;
  final LabelStyleBuilder? labelStyleBuilder;

  bool hasAnyHoverColor() {
    return hoverContourColor != null || _hoverColor != null;
  }

  Color getColor(MapFeature feature) {
    return _color;
  }

  Color? getHoverColor(MapFeature feature) {
    return _hoverColor;
  }

  TextStyle getLabelStyle(
      MapFeature feature, Color featureColor, Color labelColor, bool hover) {
    if (labelStyleBuilder != null) {
      return labelStyleBuilder!(feature, featureColor, labelColor, hover);
    }
    return TextStyle(
      color: labelColor,
      fontSize: 11,
    );
  }
}

class _MapChartThemeValue extends MapChartTheme {
  _MapChartThemeValue(
      {Color? color,
      Color? contourColor,
      Color? hoverContourColor,
      double? contourThickness,
      Color? hoverColor,
      LabelStyleBuilder? labelStyleBuilder,
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
            hoverColor: hoverColor,
            labelStyleBuilder: labelStyleBuilder);

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
      LabelStyleBuilder? labelStyleBuilder,
      required List<ColorRule> colorRules,
      List<ColorRule>? hoverColorRules})
      : this._colorRules = colorRules,
        this._hoverColorRules = hoverColorRules,
        super(
            color: color,
            contourColor: contourColor,
            hoverContourColor: hoverContourColor,
            contourThickness: contourThickness,
            hoverColor: hoverColor,
            labelStyleBuilder: labelStyleBuilder);

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
      LabelStyleBuilder? labelStyleBuilder,
      required this.min,
      required this.max,
      required this.key,
      required this.colors})
      : super(
            color: color,
            contourColor: contourColor,
            hoverContourColor: hoverContourColor,
            contourThickness: contourThickness,
            hoverColor: hoverColor,
            labelStyleBuilder: labelStyleBuilder);

  double min;
  double max;
  final String key;
  final List<Color> colors;

  @override
  Color getColor(MapFeature feature) {
    dynamic? dynamicValue = feature.getValue(key);
    double? value;
    if (dynamicValue is int) {
      value = dynamicValue.toDouble();
    } else if (dynamicValue is double) {
      value = dynamicValue;
    }
    if (value != null) {
      if (value <= min) {
        return colors.first;
      }
      if (value >= max) {
        return colors.last;
      }

      double size = max - min;

      int stepsCount = colors.length - 1;
      double stepSize = size / stepsCount;
      int stepIndex = (value - min) ~/ stepSize;

      double currentStepRange = (stepIndex * stepSize) + stepSize;
      double positionInStep = value - min - (stepIndex * stepSize);
      double t = positionInStep / currentStepRange;
      return Color.lerp(colors[stepIndex], colors[stepIndex + 1], t)!;
    }

    return super.getColor(feature);
  }

  @override
  Color? getHoverColor(MapFeature feature) {
    return super.getHoverColor(feature);
  }
}
