import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ParserPage extends StatefulWidget {
  @override
  ParserPageState createState() => ParserPageState();
}

class ParserPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource = await MapChartDataSource.geoJSON(
        geojson: geojson,
        keys: ['Seq', 'Rnd'],
        parseToNumber: ['Rnd'],
        labelKey: 'Rnd');
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme.gradient(
            labelVisibility: (feature) => true,
            key: 'Rnd',
            colors: [Colors.blue, Colors.red]));
    return map;
  }
}
