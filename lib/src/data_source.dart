import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:mapchart/src/data_reader.dart';
import 'package:mapchart/src/matrices.dart';
import 'package:mapchart/src/simplifier.dart';

class MapFeature {
  final int id;
  final FeatureProperties? properties;
  final MapGeometry geometry;

  MapFeature({required this.id, required this.geometry, this.properties});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFeature && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MapChartDataSource {
  final UnmodifiableMapView<int, MapFeature> features;
  final Rect bounds;
  final int pointsCount;

  MapChartDataSource._(this.features, this.bounds, this.pointsCount);

  static  MapChartDataSource fromFeatures(List<MapFeature> features) {
    Rect boundsFromGeometry = Rect.zero;
    int pointsCount = 0;
    if (features.isNotEmpty) {
      boundsFromGeometry = features.first.geometry.bounds;
    }
    Map<int, MapFeature> featuresMap = Map<int, MapFeature>();
    for (MapFeature feature in features) {
      featuresMap[feature.id] = feature;
      pointsCount += feature.geometry.pointsCount;
      boundsFromGeometry =
          boundsFromGeometry.expandToInclude(feature.geometry.bounds);
    }

    return MapChartDataSource._(
        UnmodifiableMapView<int, MapFeature>(featuresMap),
        boundsFromGeometry,
        pointsCount);
  }

  static Future<MapChartDataSource> fromGeoJSON(
      {required String geojson,
        String? identifierField,
        String? nameField,
        List<String>? valueFields,
        String? colorField,
        ColorFieldFormat colorFieldFormat = ColorFieldFormat.hex}) async {

    MapFeatureReader reader = MapFeatureReader(
        identifierField: identifierField,
        nameField: nameField,
        valueFields: valueFields,
        colorField: colorField,
        colorFieldFormat: colorFieldFormat);

    List<MapFeature> features= await reader.read(geojson);
    return fromFeatures(features);
  }

  factory MapChartDataSource.geometries(List<MapGeometry> geometries) {
    Rect boundsFromGeometry = Rect.zero;
    int pointsCount = 0;
    if (geometries.isNotEmpty) {
      boundsFromGeometry = geometries.first.bounds;
    }
    Map<int, MapFeature> featuresMap = Map<int, MapFeature>();
    int id = 1;
    for (MapGeometry geometry in geometries) {
      featuresMap[id] = MapFeature(id: id, geometry: geometry);
      pointsCount += geometry.pointsCount;
      boundsFromGeometry = boundsFromGeometry.expandToInclude(geometry.bounds);
      id++;
    }

    return MapChartDataSource._(
        UnmodifiableMapView<int, MapFeature>(featuresMap),
        boundsFromGeometry,
        pointsCount);
  }
}

class SimplifiedPath {
  final Path path;
  final int pointsCount;

  SimplifiedPath(this.path, this.pointsCount);
}


class FeatureProperties {
  FeatureProperties({this.identifier, this.name, this.values, this.value, this.color});

  final dynamic? identifier;
  final dynamic? name;
  final Map<String, dynamic>? values;
  final dynamic? value;
  final Color? color;
}

abstract class MapGeometry {
  SimplifiedPath toPath(
      CanvasMatrix canvasMatrix, GeometrySimplifier simplifier);
  Rect get bounds;
  int get pointsCount;
}

class MapPoint extends Offset {
  MapPoint(double x, double y) : super(x, y);

  double get x => dx;
  double get y => dy;

  @override
  String toString() {
    return 'MapPoint{x: $x, y: $y}';
  }
}

class MapLinearRing extends MapGeometry {
  final UnmodifiableListView<MapPoint> points;
  final Rect bounds;

  MapLinearRing._(this.points, this.bounds);

  factory MapLinearRing(List<MapPoint> points) {
    //TODO exception for insufficient number of points?
    MapPoint first = points.first;
    double left = first.dx;
    double right = first.dx;
    double top = first.dy;
    double bottom = first.dy;

    for (int i = 1; i < points.length; i++) {
      MapPoint point = points[i];
      left = math.min(point.dx, left);
      right = math.max(point.dx, right);
      bottom = math.max(point.dy, bottom);
      top = math.min(point.dy, top);
    }
    Rect bounds = Rect.fromLTRB(left, top, right, bottom);
    return MapLinearRing._(UnmodifiableListView<MapPoint>(points), bounds);
  }

  @override
  SimplifiedPath toPath(
      CanvasMatrix canvasMatrix, GeometrySimplifier simplifier) {
    Path path = Path();
    List<MapPoint> simplifiedPoints = simplifier.simplify(canvasMatrix, points);
    for (int i = 0; i < simplifiedPoints.length; i++) {
      MapPoint point = simplifiedPoints[i];
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return SimplifiedPath(path, simplifiedPoints.length);
  }

  @override
  int get pointsCount => points.length;
}

class MapPolygon extends MapGeometry {
  final MapLinearRing externalRing;
  final UnmodifiableListView<MapLinearRing> internalRings;
  final Rect bounds;

  MapPolygon._(this.externalRing, this.internalRings, this.bounds);

  factory MapPolygon(
      MapLinearRing externalRing, List<MapLinearRing> internalRings) {
    Rect bounds = externalRing.bounds;
    for (MapLinearRing linearRing in internalRings) {
      bounds = bounds.expandToInclude(linearRing.bounds);
    }
    return MapPolygon._(externalRing,
        UnmodifiableListView<MapLinearRing>(internalRings), bounds);
  }

  @override
  SimplifiedPath toPath(
      CanvasMatrix canvasMatrix, GeometrySimplifier simplifier) {
    Path path = Path()..fillType = PathFillType.evenOdd;
    SimplifiedPath simplifiedPath =
        externalRing.toPath(canvasMatrix, simplifier);
    int pointsCount = simplifiedPath.pointsCount;
    path.addPath(simplifiedPath.path, Offset.zero);
    for (MapLinearRing ring in internalRings) {
      simplifiedPath = ring.toPath(canvasMatrix, simplifier);
      pointsCount += simplifiedPath.pointsCount;
      path.addPath(simplifiedPath.path, Offset.zero);
    }
    return SimplifiedPath(path, pointsCount);
  }

  @override
  int get pointsCount => _getPointsCount();

  int _getPointsCount() {
    int count = externalRing.pointsCount;
    for (MapLinearRing ring in internalRings) {
      count += ring.pointsCount;
    }
    return count;
  }
}

class MapMultiPolygon extends MapGeometry {
  final UnmodifiableListView<MapPolygon> polygons;
  final Rect bounds;
  MapMultiPolygon._(this.polygons, this.bounds);

  factory MapMultiPolygon(List<MapPolygon> polygons) {
    Rect bounds = polygons.first.bounds;
    for (int i = 1; i < polygons.length; i++) {
      bounds = bounds.expandToInclude(polygons[i].bounds);
    }
    return MapMultiPolygon._(
        UnmodifiableListView<MapPolygon>(polygons), bounds);
  }

  @override
  SimplifiedPath toPath(
      CanvasMatrix canvasMatrix, GeometrySimplifier simplifier) {
    Path path = Path();
    int pointsCount = 0;
    for (MapPolygon polygon in polygons) {
      SimplifiedPath simplifiedPath = polygon.toPath(canvasMatrix, simplifier);
      pointsCount += simplifiedPath.pointsCount;
      path.addPath(simplifiedPath.path, Offset.zero);
    }
    return SimplifiedPath(path, pointsCount);
  }

  @override
  int get pointsCount => _getPointsCount();

  int _getPointsCount() {
    int count = 0;
    for (MapPolygon polygon in polygons) {
      count += polygon.pointsCount;
    }
    return count;
  }
}
