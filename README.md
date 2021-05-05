[![pub](https://img.shields.io/pub/v/mapchart.svg)](https://pub.dev/packages/mapchart)

# Map Chart

* Displays GeoJSON geometries
* Multi resolution with geometry simplification

![mapchart](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/mapchart.gif)

## Get started

Reading GeoJSON from String
```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);

    setState(() {
      _dataSource = dataSource;
    });
```

Creating the Widget
```dart
    MapChart map = MapChart(dataSource: _dataSource);
```

![getstarted](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/get_started.gif)

## Changing the default colors

```dart
    MapChart map = MapChart(
        dataSource: _dataSource,
        theme: MapChartTheme(
            color: Colors.yellow,
            contourColor: Colors.red,
            highlightColor: Colors.orange));
```

![defaultcolors](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/default_colors.png)

## Color by id

It allows mapping colors for each identifier in Json. The default color will be used if the color has not been mapped.

```dart
    MapChartDataSource dataSource = await MapChartDataSource.fromGeoJSON(
        geojson: geojson, identifierField: "Id");
```

```dart
    MapChartTheme theme = MapChartTheme(colors: {
      "earth": Colors.green,
      "mars": Colors.red,
      "venus": Colors.orange
    });

    MapChart map = MapChart(dataSource: _dataSource, theme: theme);
```

![colorbyid](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_id.png)

## Agenda for the next few days

* Release the final version (1.0.0). The API may have some small changes.