import 'dart:collection';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:convert';
import 'package:mapchart/src/error.dart';
import 'package:mapchart/src/matrices.dart';
import 'package:mapchart/src/simplifier.dart';

class SimplifiedPath {
  final Path path;
  final int pointsCount;

  SimplifiedPath(this.path, this.pointsCount);
}

abstract class MapGeometry {
  SimplifiedPath toPath(
      CanvasMatrix canvasMatrix, GeometrySimplifier simplifier);
  Rect get bounds;
  int get pointsCount;

  static _checkKeyOn(Map<String, dynamic> map, String key) {
    if (map.containsKey(key) == false) {
      throw MapChartError.keyNotFound(key);
    }
  }

  static Future<List<MapGeometry>> fromGeoJSON(String geojson) async {
    return await MapGeometry._fetchGeometries(geojson).toList();
  }

  static Stream<MapGeometry> _fetchGeometries(String geojson) async* {
    Map<String, dynamic> map = json.decode(geojson);

    MapGeometry._checkKeyOn(map, 'type');

    final type = map['type'];

    if (type == 'FeatureCollection') {
      MapGeometry._checkKeyOn(map, 'features');
      //TODO verificar se é um map?
      for (Map<String, dynamic> featureMap in map['features']) {
        MapGeometry._checkKeyOn(featureMap, 'geometry');
        Map<String, dynamic> geometryMap = featureMap['geometry'];
        MapGeometry._checkKeyOn(geometryMap, 'type');
        final geometryType = geometryMap['type'];
        MapGeometry geometry = _fetchGeometry(true, geometryMap, geometryType);
        yield geometry;
      }
    } else if (type == 'GeometryCollection') {
    } else if (type == 'Feature') {
    } else {
      MapGeometry geometry = _fetchGeometry(false, map, type);
      yield geometry;
    }
  }

  static MapGeometry _fetchGeometry(
      bool hasParent, Map<String, dynamic> map, String type) {
    switch (type) {
      //TODO other geometries
      case 'Point':
        return MapGeometry._fetchPolygon(map);
      case 'MultiPoint':
        return MapGeometry._fetchPolygon(map);
      case 'LineString':
        return MapGeometry._fetchPolygon(map);
      case 'MultiLineString':
        return MapGeometry._fetchPolygon(map);
      case 'Polygon':
        return MapGeometry._fetchPolygon(map);
      case 'MultiPolygon':
        return MapGeometry._fetchMultiPolygon(map);
      default:
        if (hasParent) {
          throw MapChartError.invalidGeometryType(type);
        } else {
          throw MapChartError.invalidType(type);
        }
    }
  }

  static MapGeometry _fetchPolygon(Map<String, dynamic> map) {
    late MapLinearRing externalRing;
    List<MapLinearRing> internalRings = [];

    MapGeometry._checkKeyOn(map, 'coordinates');
    List rings = map['coordinates'];
    for (int i = 0; i < rings.length; i++) {
      List<MapPoint> points = [];
      List ring = rings[i];
      for (List xy in ring) {
        double x = xy[0];
        double y = xy[1];
        points.add(MapPoint(x, y));
      }
      if (i == 0) {
        externalRing = MapLinearRing(points);
      } else {
        internalRings.add(MapLinearRing(points));
      }
    }

    return MapPolygon(externalRing, internalRings);
  }

  static MapGeometry _fetchMultiPolygon(Map<String, dynamic> map) {
    MapGeometry._checkKeyOn(map, 'coordinates');
    List polygons = map['coordinates'];

    List<MapPolygon> mapPolygons = [];
    for (List rings in polygons) {
      late MapLinearRing externalRing;
      List<MapLinearRing> internalRings = [];

      for (int i = 0; i < rings.length; i++) {
        List<MapPoint> points = [];
        List ring = rings[i];
        for (List xy in ring) {
          double x = xy[0];
          double y = xy[1];
          points.add(MapPoint(x, y));
        }
        if (i == 0) {
          externalRing = MapLinearRing(points);
        } else {
          internalRings.add(MapLinearRing(points));
        }
      }
      MapPolygon polygon = MapPolygon(externalRing, internalRings);
      mapPolygons.add(polygon);
    }

    return MapMultiPolygon(mapPolygons);
  }
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

class MapChartFeature {
  final int id;
  final MapGeometry geometry;

  MapChartFeature(this.id, this.geometry);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapChartFeature &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MapChartDataSource {
  final UnmodifiableMapView<int, MapChartFeature> features;
  final Rect bounds;
  final int pointsCount;

  MapChartDataSource._(this.features, this.bounds, this.pointsCount);

  factory MapChartDataSource(List<MapGeometry> geometries) {
    Rect boundsFromGeometry = Rect.zero;
    int pointsCount = 0;
    if (geometries.isNotEmpty) {
      boundsFromGeometry = geometries.first.bounds;
    }
    Map<int, MapChartFeature> features = Map<int, MapChartFeature>();
    int id = 1;
    for (MapGeometry geometry in geometries) {
      features[id] = MapChartFeature(id, geometry);
      pointsCount += geometry.pointsCount;
      boundsFromGeometry = boundsFromGeometry.expandToInclude(geometry.bounds);
      id++;
    }

    return MapChartDataSource._(
        UnmodifiableMapView<int, MapChartFeature>(features),
        boundsFromGeometry,
        pointsCount);
  }
}
