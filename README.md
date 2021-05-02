[![pub](https://img.shields.io/pub/v/tabbed_view.svg)](https://pub.dev/packages/mapchart)

# Map Chart

This package is still in alpha, but I will release a usable version in the next few days. Don't worry, it won't be long! ;-)

* Displays GeoJSON geometries
* Multi resolution with geometry simplification

![mapchart](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/mapchart.gif)

## Get started

Reading GeoJSON from String
```dart
    List<MapGeometry> geometries = await MapGeometry.fromGeoJSON(geojson);
    MapChartDataSource dataSource = MapChartDataSource(geometries);
```

Creating the Widget
```dart
    Container(
        child: MapChart(dataSource: dataSource),
        decoration: BoxDecoration(border: Border.all(color: Colors.black);
```

## Agenda for the next few days

* Release the final version (1.0.0). The API may have some small changes.