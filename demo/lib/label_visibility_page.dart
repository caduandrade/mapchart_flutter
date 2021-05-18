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

  @override
  Widget buildContent() {
    MapChart map = MapChart(dataSource: dataSource, labelVisible: true);

    return map;
  }
}
