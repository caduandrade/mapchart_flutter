import 'package:demo/menu.dart';
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class LabelVisibilityPage extends StatefulWidget {
  @override
  LabelVisibilityPageState createState() => LabelVisibilityPageState();
}

class LabelVisibilityPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, labelKey: 'Name');
    return dataSource;
  }

  List<MenuItem> buildMenuItems() {
    return [
      MenuItem('All visible', _allVisible),
      MenuItem('Visible rule', _visibleRule)
    ];
  }

  Widget _allVisible() {
    MapChart map =
        MapChart(dataSource: dataSource, labelVisibility: (feature) => true);

    return map;
  }

  Widget _visibleRule() {
    MapChart map = MapChart(
        dataSource: dataSource,
        labelVisibility: (feature) => feature.label == 'Darwin');

    return map;
  }
}
