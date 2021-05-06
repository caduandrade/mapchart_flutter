import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:mapchart/mapchart.dart';
import 'package:mapchart/src/error.dart';
import 'package:mapchart/src/matrices.dart';
import 'package:mapchart/src/data_source.dart';
import 'package:mapchart/src/theme.dart';

class MapChart extends StatefulWidget {
  MapChart(
      {Key? key,
      this.dataSource,
      this.delayToRefreshResolution = 1000,
      MapChartTheme? theme,
      this.borderColor = Colors.black54,
      this.borderThickness = 1,
      this.padding = 8,
      this.featureHoverListener})
      : this.theme = theme != null ? theme : MapChartTheme(),
        super(key: key);

  final MapChartDataSource? dataSource;
  final MapChartTheme theme;
  final int delayToRefreshResolution;
  final Color? borderColor;
  final double? borderThickness;
  final double? padding;
  final FeatureHoverListener? featureHoverListener;

  @override
  State<StatefulWidget> createState() => MapChartState();
}

typedef FeatureHoverListener = Function(MapFeature? feature);

class MapChartState extends State<MapChart> {
  MapFeature? _hover;

  MapResolution? _mapResolution;

  Size? _lastBuildSize;
  MapResolutionBuilder? _mapResolutionBuilder;

  _updateMapResolution(MapMatrices mapMatrices, Size size) {
    if (_lastBuildSize == size) {
      if (_mapResolutionBuilder != null) {
        _mapResolutionBuilder!.stop();
      }
      _mapResolutionBuilder = MapResolutionBuilder(
          dataSource: widget.dataSource!,
          theme: widget.theme,
          mapMatrices: mapMatrices,
          simplifier: IntegerSimplifier(),
          onFinish: _onFinish);
      _mapResolutionBuilder!.start();
    }
  }

  _onFinish(MapResolution newMapResolution) {
    print('simplified points: ' +
        newMapResolution.pointsCount.toString() +
        ' of ' +
        widget.dataSource!.pointsCount.toString());
    setState(() {
      _mapResolution = newMapResolution;
      _mapResolutionBuilder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Decoration? decoration;
    if (widget.borderColor != null &&
        widget.borderThickness != null &&
        widget.borderThickness! > 0) {
      decoration = BoxDecoration(
          border: Border.all(
              color: widget.borderColor!, width: widget.borderThickness!));
    }
    EdgeInsetsGeometry? padding;
    if (widget.padding != null && widget.padding! > 0) {
      padding = EdgeInsets.all(widget.padding!);
    }

    Widget? content;
    if (widget.dataSource != null) {
      content = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        int? bufferWidth;
        int? bufferHeight;
        if (_mapResolution != null) {
          bufferWidth = _mapResolution!.mapBuffer.width;
          bufferHeight = _mapResolution!.mapBuffer.height;
        }
        MapMatrices mapMatrices = MapMatrices(
            widgetWidth: constraints.maxWidth,
            widgetHeight: constraints.maxHeight,
            geometryBounds: widget.dataSource!.bounds,
            bufferWidth: bufferWidth,
            bufferHeight: bufferHeight);

        final Size size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_lastBuildSize != size) {
          _lastBuildSize = size;
          if (_mapResolution == null) {
            if (_mapResolutionBuilder == null) {
              // first build without delay
              Future.microtask(() => _updateMapResolution(mapMatrices, size));
            }
            return Center(
              child: Text('updating...'),
            );
          } else {
            // updating map resolution
            Future.delayed(
                Duration(milliseconds: widget.delayToRefreshResolution), () {
              _updateMapResolution(mapMatrices, size);
            });
          }
        }

        MapPainter mapPainter = MapPainter(
            mapResolution: _mapResolution!,
            hover: _hover,
            mapMatrices: mapMatrices,
            theme: widget.theme);

        CustomPaint customPaint =
            CustomPaint(painter: mapPainter, child: Container());

        if (widget.theme.isHoverEnabled()) {
          return MouseRegion(
            child: customPaint,
            onHover: (event) => _onHover(event, mapMatrices),
            onExit: (event) {
              if (_hover != null) {
                _updateHover(null);
              }
            },
          );
        }
        return customPaint;
      });
    }
    return Container(child: content, decoration: decoration, padding: padding);
  }

  _onHover(PointerHoverEvent event, MapMatrices mapMatrices) {
    if (_mapResolution != null) {
      Offset o = MatrixUtils.transformPoint(
          mapMatrices.canvasMatrix.screenToGeometry, event.localPosition);

      bool found = false;
      for (MapFeature feature in widget.dataSource!.features.values) {
        if (_mapResolution!.paths.containsKey(feature.id) == false) {
          throw MapChartError('No path for id: ' + feature.id.toString());
        }
        Path path = _mapResolution!.paths[feature.id]!;
        found = path.contains(o);
        if (found) {
          if (_hover != feature) {
            _updateHover(feature);
          }
          break;
        }
      }
      if (found == false && _hover != null) {
        _updateHover(null);
      }
    }
  }

  _updateHover(MapFeature? newHover) {
    setState(() {
      _hover = newHover;
    });
    if (widget.featureHoverListener != null) {
      widget.featureHoverListener!(newHover);
    }
  }
}

class MapPainter extends CustomPainter {
  MapPainter(
      {required this.mapResolution,
      required this.mapMatrices,
      required this.theme,
      this.hover});

  final MapMatrices mapMatrices;
  final MapChartTheme theme;
  final MapFeature? hover;
  final MapResolution mapResolution;

  @override
  void paint(Canvas canvas, Size size) {
    DateTime start = DateTime.now();

    // drawing the buffer

    canvas.save();
    BufferPaintMatrix matrix = mapMatrices.bufferPaintMatrix!;
    canvas.translate(matrix.translateX, matrix.translateY);
    canvas.scale(matrix.scale);
    canvas.drawImage(mapResolution.mapBuffer, Offset.zero, Paint());
    canvas.restore();

    // drawing the selection
    if (hover != null) {
      Color? hoverColor = theme.getHoverColor(hover!);
      if (hoverColor != null || theme.hoverContourColor != null) {
        canvas.save();

        CanvasMatrix canvasMatrix = mapMatrices.canvasMatrix;
        canvas.translate(canvasMatrix.translateX, canvasMatrix.translateY);
        canvas.scale(canvasMatrix.scale, -canvasMatrix.scale);

        int featureId = hover!.id;
        if (mapResolution.paths.containsKey(featureId) == false) {
          throw MapChartError('No path for id: $featureId');
        }

        Path path = mapResolution.paths[featureId]!;

        if (hoverColor != null) {
          var paint = Paint()
            ..style = PaintingStyle.fill
            ..color = hoverColor
            ..isAntiAlias = true;

          canvas.drawPath(path, paint);
        }

        if (theme.contourThickness > 0 && theme.hoverContourColor != null) {
          var paint = Paint()
            ..style = PaintingStyle.stroke
            ..color = theme.hoverContourColor!
            ..strokeWidth = theme.contourThickness / canvasMatrix.scale
            ..isAntiAlias = true;

          canvas.drawPath(path, paint);
        }

        canvas.restore();
      }
    }

    DateTime end = DateTime.now();
    Duration duration = end.difference(start);
    // print('paint time: ' + duration.inMilliseconds.toString());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
