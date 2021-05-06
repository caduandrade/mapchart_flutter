import 'package:demo/menu.dart';
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ContourPage extends StatefulWidget {
  @override
  ContourPageState createState() => ContourPageState();
}

class ContourPageState extends ExamplePageState {
  MapChartDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _loadDataSource(geojson);
  }

  _loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);

    setState(() {
      _dataSource = dataSource;
    });
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
        dataSource: _dataSource, theme: MapChartTheme(contourThickness: 3));

    return map;
  }

  Widget _noContour(BuildContext context) {
    MapChart map = MapChart(
        dataSource: _dataSource, theme: MapChartTheme(contourThickness: 0));

    return map;
  }
}
