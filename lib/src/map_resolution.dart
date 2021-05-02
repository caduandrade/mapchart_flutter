import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mapchart/mapchart.dart';
import 'package:mapchart/src/data_source.dart';
import 'package:mapchart/src/matrices.dart';
import 'package:mapchart/src/simplifier.dart';

enum _State { waiting, running, stopped }

typedef OnFinish(MapResolution newMapResolution);

class MapResolution {
  MapResolution._(
      {required this.widgetSize,
      required this.mapBuffer,
      required this.paths,
      required this.pointsCount});

  final Size widgetSize;
  final Image mapBuffer;
  final UnmodifiableMapView<int, Path> paths;
  final int pointsCount;

  Future<MemoryImage> toMemoryImageProvider() async {
    ByteData? imageByteData =
        await mapBuffer.toByteData(format: ImageByteFormat.png);
    Uint8List uint8list = imageByteData!.buffer.asUint8List();
    return MemoryImage(uint8list);
  }
}

class MapResolutionBuilder {
  MapResolutionBuilder(
      {required this.theme,
      required this.mapMatrices,
      required this.simplifier,
      required this.onFinish});

  final MapChartTheme theme;
  final MapMatrices mapMatrices;
  final GeometrySimplifier simplifier;

  final OnFinish onFinish;
  final Map<int, Path> _paths = Map<int, Path>();

  _State _state = _State.waiting;
  Map<int, MapChartFeature> _pendingFeatures = Map<int, MapChartFeature>();

  DateTime? _initialTime;

  stop() {
    _state = _State.stopped;
  }

  start(Map<int, MapChartFeature> features) async {
    _initialTime = DateTime.now();

    if (_state == _State.waiting) {
      _state = _State.running;
      _pendingFeatures.addAll(features);
      _nextPath();
    }
  }

  _nextPath() async {
    if (_state == _State.stopped) {
      return;
    }
    /*
    if(_pendingFeatures.length>0) {
      final int id = _pendingFeatures.keys.first;
      final MapChartFeature feature = _pendingFeatures.remove(id)!;
      Future((){
        print('simplifing $id');
        MapGeometry geometry = feature.geometry;
        _paths[id] = geometry.toPath(mapMatrices.canvasMatrix, simplifier);
        _nextPath();
      });
    } else {
      _createBuffer();
    }*/

    int pointsCount = 0;
    while (_pendingFeatures.length > 0) {
      final int id = _pendingFeatures.keys.first;
      final MapChartFeature feature = _pendingFeatures.remove(id)!;
      MapGeometry geometry = feature.geometry;
      SimplifiedPath simplifiedPath =
          geometry.toPath(mapMatrices.canvasMatrix, simplifier);
      pointsCount += simplifiedPath.pointsCount;
      _paths[id] = simplifiedPath.path;
    }

    Duration duration = DateTime.now().difference(_initialTime!);
    print('MapResolution - simplified geometries created in: ' +
        duration.inMilliseconds.toString() +
        'ms');

    _createBuffer(pointsCount);
  }

  _createBuffer(int pointsCount) async {
    BufferCreationMatrix bufferCreationMatrix =
        mapMatrices.bufferCreationMatrix;
    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = new Canvas(
        recorder,
        new Rect.fromPoints(
            Offset.zero,
            Offset(bufferCreationMatrix.imageWidth,
                bufferCreationMatrix.imageHeight)));

    canvas.save();

    canvas.translate(
        bufferCreationMatrix.translateX, bufferCreationMatrix.translateY);
    canvas.scale(bufferCreationMatrix.scale, -bufferCreationMatrix.scale);

    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foregoundColor
      ..isAntiAlias = true;

    for (Path path in _paths.values) {
      if (_state == _State.stopped) {
        return;
      }
      canvas.drawPath(path, paint);
    }

    if (theme.contourColor != null) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = theme.contourColor!
        ..strokeWidth = 1 / bufferCreationMatrix.scale
        ..isAntiAlias = true;

      for (Path path in _paths.values) {
        if (_state == _State.stopped) {
          return;
        }
        canvas.drawPath(path, paint);
      }
    }

    canvas.restore();

    Picture picture = recorder.endRecording();
    Image mapBuffer = await picture.toImage(
        bufferCreationMatrix.imageWidth.toInt(),
        bufferCreationMatrix.imageHeight.toInt());

    if (_state != _State.stopped) {
      onFinish(MapResolution._(
          widgetSize: mapMatrices.canvasMatrix.widgetSize,
          paths: UnmodifiableMapView(_paths),
          pointsCount: pointsCount,
          mapBuffer: mapBuffer));
    }
  }
}
