import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class DefaultColorsPage extends StatefulWidget {
  @override
  DefaultColorsPageState createState() => DefaultColorsPageState();
}

class DefaultColorsPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(
            color: Colors.yellow,
            contourColor: Colors.red,
            hoverColor: Colors.orange));

    return map;
  }
}
