import 'dart:convert';
import 'dart:ui';

import 'package:mapchart/src/data_source.dart';
import 'package:mapchart/src/error.dart';

class MapDataReader {
  _checkKeyOn(Map<String, dynamic> map, String key) {
    if (map.containsKey(key) == false) {
      throw MapChartError.keyNotFound(key);
    }
  }

  MapGeometry _readGeometry(bool hasParent, Map<String, dynamic> map) {
    _checkKeyOn(map, 'type');
    final type = map['type'];
    switch (type) {
      //TODO other geometries
      case 'Point':
        return _readPolygon(map);
      case 'MultiPoint':
        return _readPolygon(map);
      case 'LineString':
        return _readPolygon(map);
      case 'MultiLineString':
        return _readPolygon(map);
      case 'Polygon':
        return _readPolygon(map);
      case 'MultiPolygon':
        return _readMultiPolygon(map);
      default:
        if (hasParent) {
          throw MapChartError.invalidGeometryType(type);
        } else {
          throw MapChartError.invalidType(type);
        }
    }
  }

  MapGeometry _readPolygon(Map<String, dynamic> map) {
    late MapLinearRing externalRing;
    List<MapLinearRing> internalRings = [];

    _checkKeyOn(map, 'coordinates');
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

  MapGeometry _readMultiPolygon(Map<String, dynamic> map) {
    _checkKeyOn(map, 'coordinates');
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

enum ColorFieldFormat { hex }

class MapFeatureReader extends MapDataReader {
  MapFeatureReader(
      {this.identifierField,
      this.nameField,
      this.valueFields,
      this.colorField,
      this.colorFieldFormat = ColorFieldFormat.hex});

  final List<MapFeature> _list = [];

  final String? identifierField;
  final String? nameField;
  final List<String>? valueFields;
  final String? colorField;
  final ColorFieldFormat colorFieldFormat;

  Future<List<MapFeature>> read(String geojson) async {
    Map<String, dynamic> map = json.decode(geojson);
    await _readMap(map);
    return _list;
  }

  _readMap(Map<String, dynamic> map) async {
    _checkKeyOn(map, 'type');

    final type = map['type'];

    if (type == 'FeatureCollection') {
      _checkKeyOn(map, 'features');
      //TODO check if it is a Map?
      for (Map<String, dynamic> featureMap in map['features']) {
        _readFeature(featureMap);
      }
    } else if (type == 'GeometryCollection') {
    } else if (type == 'Feature') {
      _readFeature(map);
    } else {
      MapGeometry geometry = _readGeometry(false, map);
      _addFeature(geometry: geometry);
    }
  }

  _readFeature(Map<String, dynamic> map) {
    _checkKeyOn(map, 'geometry');
    Map<String, dynamic> geometryMap = map['geometry'];
    MapGeometry geometry = _readGeometry(true, geometryMap);
    FeatureProperties? properties;
    if ((identifierField != null ||
            nameField != null ||
            valueFields != null ||
            colorField != null) &&
        map.containsKey('properties')) {
      Map<String, dynamic> propertiesMap = map['properties'];
      properties = _readProperties(propertiesMap);
    }
    _addFeature(geometry: geometry, properties: properties);
  }

  FeatureProperties _readProperties(Map<String, dynamic> map) {
    dynamic? identifier;
    dynamic? name;
    Map<String, dynamic>? values;
    Color? color;
    if (identifierField != null && map.containsKey(identifierField)) {
      identifier = map[identifierField];
    }
    if (nameField != null && map.containsKey(nameField)) {
      name = map[nameField];
    }
    if (valueFields != null) {
      if (valueFields!.isNotEmpty) {
        Map<String, dynamic> valuesTmp = Map<String, dynamic>();
        for (String valueField in valueFields!) {
          if (map.containsKey(valueField)) {
            valuesTmp[valueField] = map[valueField];
          }
        }
        if (valuesTmp.isNotEmpty) {
          values = valuesTmp;
        }
      }
    }
    return FeatureProperties(
        identifier: identifier, name: name, values: values, color: color);
  }

  _addFeature({required MapGeometry geometry, FeatureProperties? properties}) {
    _list.add(MapFeature(
        id: _list.length + 1, geometry: geometry, properties: properties));
  }
}

class MapGeometryReader extends MapDataReader {
  final List<MapGeometry> _list = [];

  Future<List<MapGeometry>> geoJSON(String geojson) async {
    Map<String, dynamic> map = json.decode(geojson);
    await _readMap(map);
    return _list;
  }

  _readMap(Map<String, dynamic> map) async {
    _checkKeyOn(map, 'type');

    final type = map['type'];

    if (type == 'FeatureCollection') {
      _checkKeyOn(map, 'features');
      //TODO check if it is a Map?
      for (Map<String, dynamic> featureMap in map['features']) {
        _readFeature(featureMap);
      }
    } else if (type == 'GeometryCollection') {
    } else if (type == 'Feature') {
      _readFeature(map);
    } else {
      MapGeometry geometry = _readGeometry(false, map);
      _list.add(geometry);
    }
  }

  _readFeature(Map<String, dynamic> map) {
    _checkKeyOn(map, 'geometry');
    Map<String, dynamic> geometryMap = map['geometry'];
    MapGeometry geometry = _readGeometry(true, geometryMap);
    _list.add(geometry);
  }
}
