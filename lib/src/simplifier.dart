import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:mapchart/src/matrices.dart';

import 'data_source.dart';

abstract class GeometrySimplifier {
  GeometrySimplifier(this.tolerance);

  final double tolerance;

  List<MapPoint> simplify(CanvasMatrix canvasMatrix, List<MapPoint> points);

  MapPoint transformPoint(Matrix4 transform, MapPoint point) {
    final Float64List storage = transform.storage;
    final double x = point.x;
    final double y = point.y;

    // Directly simulate the transform of the vector (x, y, 0, 1),
    // dropping the resulting Z coordinate, and normalizing only
    // if needed.

    final double rx = storage[0] * x + storage[4] * y + storage[12];
    final double ry = storage[1] * x + storage[5] * y + storage[13];
    final double rw = storage[3] * x + storage[7] * y + storage[15];
    if (rw == 1.0) {
      return MapPoint(rx, ry);
    } else {
      return MapPoint(rx / rw, ry / rw);
    }
  }
}

class IntegerSimplifier extends GeometrySimplifier {
  IntegerSimplifier({double tolerance = 0}) : super(tolerance);

  @override
  List<MapPoint> simplify(CanvasMatrix canvasMatrix, List<MapPoint> points) {
    List<MapPoint> simplifiedPoints = [];
    MapPoint? lastMapPoint;
    for (MapPoint point in points) {
      MapPoint transformedPoint =
          transformPoint(canvasMatrix.geometryToScreen, point);

      transformedPoint = MapPoint(transformedPoint.x.truncateToDouble(),
          transformedPoint.y.truncateToDouble());
      if (simplifiedPoints.isEmpty ||
          _accept(lastMapPoint!, transformedPoint)) {
        simplifiedPoints.add(point);
      }
      lastMapPoint = transformedPoint;
    }
    return simplifiedPoints;
  }

  bool _accept(MapPoint p1, MapPoint p2) {
    double dx = (p1.x - p2.x).abs();
    if (dx > tolerance) {
      return true;
    }
    double dy = (p1.y - p2.y).abs();
    return dy > tolerance;
  }
}

class NoSimplifier extends GeometrySimplifier {
  NoSimplifier(double tolerance) : super(tolerance);

  @override
  List<MapPoint> simplify(CanvasMatrix canvasMatrix, List<MapPoint> points) {
    return points;
  }
}
