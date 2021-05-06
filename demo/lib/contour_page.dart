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
      MenuItem('No contour', _noContour)
    ];
  }

  Widget _thickness(BuildContext context) {
    MapChart map = MapChart(
        dataSource: dataSource, theme: MapChartTheme(contourThickness: 3));

    return map;
  }

  Widget _noContour(BuildContext context) {
    MapChart map = MapChart(
        dataSource: dataSource, theme: MapChartTheme(contourThickness: 0));

    return map;
  }
}
