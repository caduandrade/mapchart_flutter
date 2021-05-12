import 'package:demo/menu.dart';
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
  List<MenuItem> buildMenuItems() {
    return [
      MenuItem('Auto min max', _autoMinMax),
      MenuItem('Min max', _minMax)
    ];
  }

  Widget _autoMinMax() {
    if (dataSource == null) {
      return MapChart();
    }

    MapChartTheme theme = MapChartTheme.gradient(
        dataSource: dataSource,
        contourColor: Colors.white,
        key: 'Seq',
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }

  Widget _minMax() {
    MapChartTheme theme = MapChartTheme.gradient(
        contourColor: Colors.white,
        key: 'Seq',
        min: 3,
        max: 9,
        colors: [Colors.blue, Colors.yellow, Colors.red]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }
}
