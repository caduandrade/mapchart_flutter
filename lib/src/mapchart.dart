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
      this.padding = 8})
      : this.theme = theme != null ? theme : MapChartTheme(),
        super(key: key);

  final MapChartDataSource? dataSource;
  final MapChartTheme theme;
  final int delayToRefreshResolution;
  final Color? borderColor;
  final double? borderThickness;
  final double? padding;

  @override
  State<StatefulWidget> createState() => MapChartState();
}

class MapChartState extends State<MapChart> {
  MapFeature? _highlightedFeature;

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
            highlightedFeature: _highlightedFeature,
            mapMatrices: mapMatrices,
            theme: widget.theme);

        return MouseRegion(
            child: CustomPaint(painter: mapPainter, child: Container()),
            onHover: (event) => _onHover(event, mapMatrices));
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
          if (_highlightedFeature != feature) {
            setState(() {
              _highlightedFeature = feature;
            });
          }
          break;
        }
      }
      if (found == false && _highlightedFeature != null) {
        setState(() {
          _highlightedFeature = null;
        });
      }
    }
  }
}

class MapPainter extends CustomPainter {
  MapPainter(
      {required this.mapResolution,
      required this.mapMatrices,
      required this.theme,
      this.highlightedFeature});

  final MapMatrices mapMatrices;
  final MapChartTheme theme;
  final MapFeature? highlightedFeature;
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
    if (highlightedFeature != null) {
      canvas.save();

      CanvasMatrix canvasMatrix = mapMatrices.canvasMatrix;
      canvas.translate(canvasMatrix.translateX, canvasMatrix.translateY);
      canvas.scale(canvasMatrix.scale, -canvasMatrix.scale);

      var hoverPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = theme.getHighlightColor(highlightedFeature!)
        ..isAntiAlias = true;

      int highlightedFeatureId = highlightedFeature!.id;
      if (mapResolution.paths.containsKey(highlightedFeatureId) == false) {
        throw MapChartError('No path for id: $highlightedFeatureId');
      }
      Path path = mapResolution.paths[highlightedFeatureId]!;
      canvas.drawPath(path, hoverPaint);

      canvas.restore();
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
