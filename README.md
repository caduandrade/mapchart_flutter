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

## Color by property value

Sets a color for each property value in GeoJSON. If a color is not set, the default color is used.

##### Mapping the property key

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, valueKeys: ['Id']);
```

##### Setting the colors for the property values

```dart
    MapChartTheme theme =
        MapChartTheme.value(contourColor: Colors.white, key: 'Id', colors: {
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

![colorbyvalue](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_value.gif)

## Color by rule

The feature color is obtained from the first rule that returns a non-null color. If all rules return a null color, the default color is used.

##### Mapping the property key

```dart
    MapChartDataSource dataSource = await MapChartDataSource.geoJSON(
        geojson: geojson, valueKeys: ['Distance']);
```

##### Setting the rules

```dart
    MapChartTheme theme = MapChartTheme.rule(
        contourColor: Colors.white,
        hoverColor: Colors.grey[700]!,
        colorRules: [
          (feature) {
            return feature.getValue('Distance') < 100000000
                ? Colors.green
                : null;
          },
          (feature) {
            return feature.getValue('Distance') < 200000000
                ? Colors.blue
                : null;
          }
        ]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![colorbyrule](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_rule.png)

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
        theme: MapChartTheme(hoverContourColor: Colors.red));
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

##### Enabling hover by property value

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, valueKeys: ['Id']);
```

```dart
    // coloring only the 'earth' feature
    MapChartTheme theme = MapChartTheme.value(
        key: 'Id',
        colors: {'earth': Colors.green},
        hoverColor: Colors.green[900]!);

    // enabling hover only for the 'earth' feature
    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverRule: (feature) {
        return feature.getValue('Id') == 'earth';
      },
    );
```

![hoverbyvalue](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/enable_hover_by_value.gif)

## Click listener

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(hoverColor: Colors.grey[800]!),
        clickListener: (feature) {
          print(feature.id);
        });
```

## Agenda for the next few days

* More theming features.
* Legend.
* Release the final version (1.0.0). The API may have some small changes.