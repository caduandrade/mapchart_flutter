[![pub](https://img.shields.io/pub/v/mapchart.svg)](https://pub.dev/packages/mapchart) ![pub2](https://img.shields.io/badge/final%20version-as%20soon%20as%20possible-blue)

# Map Chart

* Displays GeoJSON geometries
* Multi resolution with geometry simplification
* Highly customizable
* Interactable
* Pure Flutter (no WebView/JavaScript)

![mapchart](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/mapchart.gif)

## Get started

A simplified GeoJSON will be used in the examples to demonstrate the different possibilities of themes. This GeoJSON has only 4 features with the following properties:

Id | Name | Satellites | Distance
--- | --- | --- | ---
venus | Venus | | 108200000
earth | Earth | Moon | 149600000
mars | Mars | Phobos, Deimos | 227900000
mercury | Mercury | | 57910000

To view the full content, use this [link](https://raw.githubusercontent.com/caduandrade/mapchart_flutter/main/demo/assets/example.json).

The following examples will assume that GeoJSON has already been loaded into a String.

##### Reading GeoJSON from String

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson);
```

##### Creating the Widget

```dart
    MapChart map = MapChart(dataSource: dataSource);
```

![getstarted](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/get_started.png)

## Changing the default colors

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(
            color: Colors.yellow,
            contourColor: Colors.red,
            hoverColor: Colors.orange));
```

![defaultcolors](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/default_colors.png)

## Color by identifier property value

Sets a color for each identifier in GeoJSON. If a color is not set for an identifier, the default color is used.

##### Mapping the identifier property key

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, identifierKey: 'Id');
```

##### Setting the colors for the identifiers

```dart
    MapChartTheme theme =
        MapChartTheme.identifier(contourColor: Colors.white, colors: {
      'earth': Colors.green,
      'mars': Colors.red,
      'venus': Colors.orange
    }, hoverColors: {
      'earth': Colors.green[900]!,
      'mars': Colors.red[900]!,
      'venus': Colors.orange[900]!
    });

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![colorbyid](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_id.gif)

## Contour

#### Thickness

```dart
    MapChart map = MapChart(
        dataSource: dataSource, theme: MapChartTheme(contourThickness: 3));
```

![contourthickness](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/contour_thickness.png)

#### Hover contour color

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(hoverContourColor: Colors.red, hoverColor: null));
```

![contourhovercolor](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/hover_contour.png)

## Hover

#### Listener

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(hoverColor: Colors.grey[700]),
        hoverListener: (MapFeature? feature) {
          if (feature != null) {
            int id = feature.id;
            print('Hover - Feature id: $id');
          }
        });
```

#### Rule

##### Enabling hover by identifier

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, identifierKey: 'Id');
```

```dart
    MapChartTheme theme = MapChartTheme.identifier(
        colors: {'earth': Colors.green}, hoverColor: Colors.green[900]!);

    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverRule: (feature) {
        return feature.properties?.identifier == 'earth';
      },
    );
```

![hoverbyid](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/enable_hover_by_id.gif)

## Agenda for the next few days

* More theming features.
* Legend.
* Release the final version (1.0.0). The API may have some small changes.