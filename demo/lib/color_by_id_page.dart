import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ColorByIdPage extends StatefulWidget {
  @override
  ColorByIdPageState createState() => ColorByIdPageState();
}

class ColorByIdPageState extends ExamplePageState {
  MapChartDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _loadDataSource(geojson);
  }

  _loadDataSource(String geojson) async {
    MapChartDataSource dataSource = await MapChartDataSource.fromGeoJSON(
        geojson: geojson, identifierField: "Id");

    setState(() {
      _dataSource = dataSource;
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    MapChartTheme theme = MapChartTheme(colors: {
      "earth": Colors.green,
      "mars": Colors.red,
      "venus": Colors.orange
    });

    MapChart map = MapChart(dataSource: _dataSource, theme: theme);

    return map;
  }
}
