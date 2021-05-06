import 'package:demo/menu.dart';
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ContourPage extends StatefulWidget {
  @override
  ContourPageState createState() => ContourPageState();
}

class ContourPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  List<MenuItem> buildMenuItems() {
    return [
      MenuItem('Thickness', _thickness),
      MenuItem('No contour', _noContour),
      MenuItem('Hover contour', _hoverContourColor)
    ];
  }

  Widget _thickness() {
    MapChart map = MapChart(
        dataSource: dataSource, theme: MapChartTheme(contourThickness: 3));

    return map;
  }

  Widget _noContour() {
    MapChart map = MapChart(
        dataSource: dataSource, theme: MapChartTheme(contourThickness: 0));

    return map;
  }

  Widget _hoverContourColor() {
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(hoverContourColor: Colors.red, hoverColor: null));

    return map;
  }
}
