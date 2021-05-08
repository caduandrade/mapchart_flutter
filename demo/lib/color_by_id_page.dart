import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ColorByIdPage extends StatefulWidget {
  @override
  ColorByIdPageState createState() => ColorByIdPageState();
}

class ColorByIdPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, identifierKey: 'Id');
    return dataSource;
  }

  @override
  Widget buildContent() {
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

    return map;
  }
}
