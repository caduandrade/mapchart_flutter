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
      required this.dataSource,
      this.delayToRefreshResolution = 1000,
      MapChartTheme? theme})
      : this.theme = theme != null ? theme : MapChartTheme(),
        super(key: key);

  final MapChartDataSource dataSource;
  final MapChartTheme theme;
  final int delayToRefreshResolution;

  @override
  State<StatefulWidget> createState() => MapChartState();
}

class MapChartState extends State<MapChart> {
  int? hoverId;

  MapResolution? _mapResolution;

  Size? _lastBuildSize;
  MapResolutionBuilder? _mapResolutionBuilder;

  _updateMapResolution(MapMatrices mapMatrices, Size size) {
    if (_lastBuildSize == size) {
      if (_mapResolutionBuilder != null) {
        _mapResolutionBuilder!.stop();
      }
      _mapResolutionBuilder = MapResolutionBuilder(
          dataSource: widget.dataSource,
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
        widget.dataSource.pointsCount.toString());
    setState(() {
      _mapResolution = newMapResolution;
      _mapResolutionBuilder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
          geometryBounds: widget.dataSource.bounds,
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
          hoverId: hoverId,
          mapMatrices: mapMatrices,
          theme: widget.theme);

      return MouseRegion(
          child: CustomPaint(painter: mapPainter, child: Container()),
          onHover: (event) => _onHover(event, mapMatrices));
    });
  }

  _onHover(PointerHoverEvent event, MapMatrices mapMatrices) {
    if (_mapResolution != null) {
      Offset o = MatrixUtils.transformPoint(
          mapMatrices.canvasMatrix.screenToGeometry, event.localPosition);

      bool found = false;
      for (int id in widget.dataSource.features.keys) {
        if (_mapResolution!.paths.containsKey(id) == false) {
          throw MapChartError('No path for id: $id');
        }
        Path path = _mapResolution!.paths[id]!;
        found = path.contains(o);
        if (found) {
          if (hoverId != id) {
            setState(() {
              hoverId = id;
            });
          }
          break;
        }
      }
      if (found == false && hoverId != null) {
        setState(() {
          hoverId = null;
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
      this.hoverId});

  final MapMatrices mapMatrices;
  final MapChartTheme theme;
  final int? hoverId;
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
    if (hoverId != null) {
      canvas.save();

      CanvasMatrix canvasMatrix = mapMatrices.canvasMatrix;
      canvas.translate(canvasMatrix.translateX, canvasMatrix.translateY);
      canvas.scale(canvasMatrix.scale, -canvasMatrix.scale);

      var hoverPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red
        ..isAntiAlias = true;

      if (mapResolution.paths.containsKey(hoverId) == false) {
        throw MapChartError('No path for id: $hoverId');
      }
      Path path = mapResolution.paths[hoverId]!;
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
