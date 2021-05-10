import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class GradientPage extends StatefulWidget {
  @override
  GradientPageState createState() => GradientPageState();
}

class GradientPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChartTheme theme = MapChartTheme.gradient(
        contourColor: Colors.white,
        key: 'Seq',
        min: 1,
        max: 11,
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }
}
