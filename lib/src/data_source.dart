import 'dart:collection';
import 'dart:ui';
import 'dart:math' as math;
import 'package:mapchart/src/data_reader.dart';
import 'package:mapchart/src/matrices.dart';
import 'package:mapchart/src/simplifier.dart';

class MapFeature {
  MapFeature(
      {required this.id,
      required this.geometry,
      Map<String, dynamic>? properties,
      this.color,
      this.label})
      : this._properties = properties;

  final int id;
  final String? label;
  final Map<String, dynamic>? _properties;
  final Color? color;
  final MapGeometry geometry;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFeature && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  dynamic? getValue(String key) {
    if (_properties != null && _properties!.containsKey(key)) {
      return _properties![key];
    }
    return null;
  }

  double? getDoubleValue(String key) {
    dynamic? d = getValue(key);
    if (d != null) {
      if (d is double) {
        return d;
      } else if (d is int) {
        return d.toDouble();
      }
    }
    return null;
  }
}

class PropertyLimits {
  double _max;
  double _min;

  PropertyLimits(double value)
      : this._max = value,
        this._min = value;

  double get max => _max;
  double get min => _min;

  expand(double value) {
    _max = math.max(_max, value);
    _min = math.min(_min, value);
  }
}

class MapChartDataSource {
  MapChartDataSource._(
      {required this.features,
      required this.bounds,
      required this.pointsCount,
      Map<String, PropertyLimits>? limits})
      : this._limits = limits;

  final UnmodifiableMapView<int, MapFeature> features;
  final Rect bounds;
  final int pointsCount;
  final Map<String, PropertyLimits>? _limits;

  static MapChartDataSource fromFeatures(List<MapFeature> features) {
    Rect boundsFromGeometry = Rect.zero;
    int pointsCount = 0;
    if (features.isNotEmpty) {
      boundsFromGeometry = features.first.geometry.bounds;
    }
    Map<String, PropertyLimits> limits = Map<String, PropertyLimits>();
    Map<int, MapFeature> featuresMap = Map<int, MapFeature>();
    for (MapFeature feature in features) {
      featuresMap[feature.id] = feature;
      pointsCount += feature.geometry.pointsCount;
      boundsFromGeometry =
          boundsFromGeometry.expandToInclude(feature.geometry.bounds);
      if (feature._properties != null) {
        feature._properties!.entries.forEach((entry) {
          dynamic value = entry.value;
          double? doubleValue;
          if (value is int) {
            doubleValue = value.toDouble();
          } else if (value is double) {
            doubleValue = value;
          }
          if (doubleValue != null) {
            String key = entry.key;
            if (limits.containsKey(key)) {
              PropertyLimits propertyLimits = limits[key]!;
              propertyLimits.expand(doubleValue);
            } else {
              limits[key] = PropertyLimits(doubleValue);
            }
          }
        });
      }
    }

    return MapChartDataSource._(
        features: UnmodifiableMapView<int, MapFeature>(featuresMap),
        bounds: boundsFromGeometry,
        pointsCount: pointsCount,
        limits: limits.isNotEmpty ? limits : null);
  }

  /// Loads a [MapChartDataSource] from GeoJSON.
  /// Geometries are always loaded.
  /// The [keys] argument defines which properties must be loaded.
  /// The [parseToNumber] argument defines which properties will have
  /// numeric values in quotes parsed to numbers.
  static Future<MapChartDataSource> geoJSON(
      {required String geojson,
      String? labelKey,
      List<String>? keys,
      List<String>? parseToNumber,
      String? colorKey,
      ColorValueFormat colorValueFormat = ColorValueFormat.hex}) async {
    MapFeatureReader reader = MapFeatureReader(
        labelKey: labelKey,
        keys: keys != null ? keys.toSet() : null,
        parseToNumber: parseToNumber != null ? parseToNumber.toSet() : null,
        colorKey: colorKey,
        colorValueFormat: colorValueFormat);

    List<MapFeature> features = await reader.read(geojson);
    return fromFeatures(features);
  }

  /// Loads a [MapChartDataSource] from geometries.
  /// MapChartDataSource features will have no properties.
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
        features: UnmodifiableMapView<int, MapFeature>(featuresMap),
        bounds: boundsFromGeometry,
        pointsCount: pointsCount);
  }

  PropertyLimits? getPropertyLimits(String key) {
    if (_limits != null && _limits!.containsKey(key)) {
      return _limits![key]!;
    }
    return null;
  }
}

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
