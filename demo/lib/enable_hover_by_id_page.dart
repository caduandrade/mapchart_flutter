import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class EnableHoverByIdPage extends StatefulWidget {
  @override
  EnableHoverByIdPageState createState() => EnableHoverByIdPageState();
}

class EnableHoverByIdPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, identifierKey: 'Id');
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChartTheme theme = MapChartTheme.identifier(
        colors: {'earth': Colors.green}, hoverColor: Colors.green[900]!);

    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverRule: (feature) {
        return feature.properties?.identifier == 'earth';
      },
    );

    return map;
  }
}
