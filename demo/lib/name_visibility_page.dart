import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class NameVisibilityPage extends StatefulWidget {
  @override
  NameVisibilityPageState createState() => NameVisibilityPageState();
}

class NameVisibilityPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, nameKey: 'Name');
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(
        dataSource: dataSource,
        nameVisible: true,
        theme: MapChartTheme(
            color: Colors.yellow,
            contourColor: Colors.red,
            hoverColor: Colors.orange));

    return map;
  }
}
