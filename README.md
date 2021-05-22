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

Name | Seq | Rnd
--- | --- | ---
"Einstein" | 1 | "73"
"Newton" | 2 | "92"
"Galileu" | 3 | "10"
"Darwin" | 4 |
"Pasteur" | 5 | "77"
"Faraday" | 6 | "32"
"Arquimedes" | 7 | "87"
"Tesla" | 8 | "17"
"Lavoisier" | 9 |
"Kepler" | 10 | "32"
"Turing" | 11 | "93"

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

##### Reading GeoJSON properties

The `keys` argument defines which properties must be loaded.
The `parseToNumber` argument defines which properties will have numeric values in quotes parsed to numbers.

```dart
    MapChartDataSource dataSource = await MapChartDataSource.geoJSON(
        geojson: geojson, keys: ['Seq', 'Rnd'], parseToNumber: ['Rnd']);
```

## Default colors

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(color: Colors.yellow, contourColor: Colors.red));
```

![defaultcolors](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/default_colors.png)

## Color by property value

Sets a color for each property value in GeoJSON. If a color is not set, the default color is used.

##### Mapping the property key

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

##### Setting the colors for the property values

```dart
    MapChartTheme theme = MapChartTheme.value(
        contourColor: Colors.white,
        key: 'Seq',
        colors: {
          2: Colors.green,
          4: Colors.red,
          6: Colors.orange,
          8: Colors.blue
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
    MapChartTheme theme =
        MapChartTheme.rule(contourColor: Colors.white, colorRules: [
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
        contourColor: Colors.white,
        key: 'Seq',
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);
```

![gradientauto](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/gradient_auto.png)

#### Setting min or max values manually

If the `min` value is set, all lower values will be displayed using the first gradient color.
If the `max` value is set, all higher values will be displayed using the last gradient color.

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
```

```dart
    MapChartTheme theme = MapChartTheme.gradient(
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
    MapChart map = MapChart(dataSource: dataSource, contourThickness: 3);
```

![contourthickness](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/contour_thickness.png)

## Label

#### Mapping label property

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, labelKey: 'Name');
```

#### Visibility

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(labelVisibility: (feature) => true));
```

![labelvisible](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/label_visible.png)

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(
            labelVisibility: (feature) => feature.label == 'Darwin'));
```

![labelrule](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/label_rule.png)

#### Style

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(
            labelVisibility: (feature) => true,
            labelStyleBuilder: (feature, featureColor, labelColor) {
              if (feature.label == 'Darwin') {
                return TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                );
              }
              return TextStyle(
                color: labelColor,
                fontSize: 11,
              );
            }));
```

![labelstyle](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/label_style.png)

## Hover

#### Color

```dart
    MapChart map = MapChart(
        dataSource: dataSource, hoverTheme: MapChartTheme(color: Colors.green));
```

![hovercolor](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/hover_color.png)

#### Contour color

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        hoverTheme: MapChartTheme(contourColor: Colors.red));
```

![contourhovercolor](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/hover_contour.png)

#### Label

```dart
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, labelKey: 'Name');
```

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        hoverTheme: MapChartTheme(labelVisibility: (feature) => true));
```

![labelhover](https://raw.githubusercontent.com/caduandrade/images/main/mapchart/label_hover.png)

#### Listener

```dart
    MapChart map = MapChart(
        dataSource: dataSource,
        hoverTheme: MapChartTheme(color: Colors.grey[700]),
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
    MapChartTheme theme =
        MapChartTheme.value(key: 'Seq', colors: {4: Colors.green});
    MapChartTheme hoverTheme = MapChartTheme(color: Colors.green[900]!);

    // enabling hover only for the 'Darwin' feature
    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverTheme: hoverTheme,
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
        hoverTheme: MapChartTheme(color: Colors.grey[800]!),
        clickListener: (feature) {
          print(feature.id);
        });
```

## Agenda for the next few days

* More theming features.
* Legend.
* Release the final version (1.0.0). The API may have some small changes.