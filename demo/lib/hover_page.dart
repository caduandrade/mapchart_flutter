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
        await MapChartDataSource.geoJSON(geojson: geojson, labelKey: 'Name');
    return dataSource;
  }

  @override
  List<MenuItem> buildMenuItems() {
    return [
      MenuItem('Color', _color),
      MenuItem('Contour', _contourColor),
      MenuItem('Label', _label),
      MenuItem('Override', _override)
    ];
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

  Widget _label() {
    MapChart map = MapChart(
        dataSource: dataSource,
        hoverTheme: MapChartTheme(labelVisibility: (feature) => true));

    return map;
  }

  Widget _override() {
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(
            color: Colors.white, labelVisibility: (feature) => false),
        hoverTheme: MapChartTheme.rule(colorRules: [
          (feature) {
            return feature.label == 'Galileu' ? Colors.blue : null;
          }
        ], labelVisibility: (feature) => feature.label == 'Galileu'));

    return map;
  }
}
