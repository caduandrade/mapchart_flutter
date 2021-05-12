[![pub](https://img.shields.io/pub/v/mapchart.svg)](https://pub.dev/packages/mapchart) [![pub2](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) ![pub3](https://img.shields.io/badge/final%20version-as%20soon%20as%20possible-blue)

# Map Chart

* Displays GeoJSON geometries
* Multi resolution with geometry simplification
* Highly customizable
* Interactable
* Pure Flutter (no WebView/JavaScript)

![mapchart](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/mapchart.gif)

## Get started

A simplified GeoJSON will be used in the examples to demonstrate the different possibilities of themes. This GeoJSON has only 4 features with the following properties:

Name | Seq
--- | ---
Einstein | 1
Newton | 2
Galileu | 3
Darwin | 4
Pasteur | 5
Faraday | 6
Arquimedes | 7
Tesla | 8
Lavoisier | 9
Kepler | 10
Turing | 11

To view the full content, use this [link](https://raw.githubusercontent.com/caduandrade/mapchart_flutter/main/demo/assets/example.json).

The following examples will assume that GeoJSON has already been loaded into a String.

##### Reading GeoJSON from String

No properties are loaded, only the geometries.

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

Only properties with a mapped key are loaded.

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

##### Setting the colors for the property values

```dart
    MapChartTheme theme =
        MapChartTheme.value(contourColor: Colors.white, key: 'Seq', colors: {
      2: Colors.green,
      4: Colors.red,
      6: Colors.orange,
      8: Colors.blue
    }, hoverColors: {
      2: Colors.green[900]!,
      4: Colors.red[900]!,
      6: Colors.orange[900]!,
      8: Colors.blue[900]!
    });

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![colorbyvalue](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_value.png)

## Color by rule

The feature color is obtained from the first rule that returns a non-null color. If all rules return a null color, the default color is used.

##### Mapping the property key

```dart
    MapChartDataSource dataSource = await MapChartDataSource.geoJSON(
        geojson: geojson, keys: ['Name', 'Seq']);
```

##### Setting the rules

```dart
    MapChartTheme theme = MapChartTheme.rule(
        contourColor: Colors.white,
        hoverColor: Colors.grey[700]!,
        colorRules: [
          (feature) {
            String? value = feature.getValue('Name');
            return value == 'Faraday' ? Colors.red : null;
          },
          (feature) {
            double? value = feature.getDoubleValue('Seq');
            return value != null && value < 3 ? Colors.green : null;
          },
          (feature) {
            double? value = feature.getDoubleValue('Seq');
            return value != null && value > 9 ? Colors.blue : null;
          }
        ]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![colorbyrule](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/color_by_rule.png)

## Gradient

The gradient is created given the colors and limit values of the chosen property.
The property must have numeric values.

#### Auto min/max values

Uses the min and max values read from data source.

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

```dart
    MapChartTheme theme = MapChartTheme.gradient(
        dataSource: dataSource!,
        contourColor: Colors.white,
        key: 'Seq',
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![gradientauto](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/gradient_auto.png)

#### Setting min or max values manually

If the min value is set, all smaller values will return the first color of the gradient.
If the max value is set, all larger values will return the last color of the gradient.

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

```dart
    MapChartTheme theme = MapChartTheme.gradient(
        dataSource: dataSource!,
        contourColor: Colors.white,
        key: 'Seq',
        min: 3,
        max: 9,
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![gradientminmax](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/gradient_min_max.png)

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
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

```dart
    // coloring only the 'Darwin' feature
    MapChartTheme theme = MapChartTheme.value(
        key: 'Seq', colors: {4: Colors.green}, hoverColor: Colors.green[900]!);

    // enabling hover only for the 'Darwin' feature
    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverRule: (feature) {
        return feature.getValue('Seq') == 4;
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