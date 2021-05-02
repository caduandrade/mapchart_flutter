class MapChartError extends Error {
  final String _message;

  MapChartError(this._message);

  MapChartError.keyNotFound(String key)
      : this._message = 'Key "$key" not found.';

  MapChartError.invalidType(String type)
      : this._message =
            'Invalid "$type" type. Must be: FeatureCollection, GeometryCollection, Feature, Point, MultiPoint, LineString, MultiLineString, Polygon or MultiPolygon.';

  MapChartError.invalidGeometryType(String type)
      : this._message =
            'Invalid geometry "$type" type. Must be: GeometryCollection, Point, MultiPoint, LineString, MultiLineString, Polygon or MultiPolygon.';

  @override
  String toString() {
    return 'GeoJSON - $_message';
  }
}
