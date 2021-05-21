import 'package:demo/menu.dart';
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class HoverPage extends StatefulWidget {
  @override
  HoverPageState createState() => HoverPageState();
}

class HoverPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  List<MenuItem> buildMenuItems() {
    return [MenuItem('Color', _color), MenuItem('Contour', _contourColor)];
  }

  Widget _color() {
    MapChart map = MapChart(
        dataSource: dataSource, hoverTheme: MapChartTheme(color: Colors.green));

    return map;
  }

  Widget _contourColor() {
    MapChart map = MapChart(
        dataSource: dataSource,
        hoverTheme: MapChartTheme(contourColor: Colors.red));

    return map;
  }
}
