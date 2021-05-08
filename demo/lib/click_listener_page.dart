import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ClickListenerPage extends StatefulWidget {
  @override
  ClickListenerPageState createState() => ClickListenerPageState();
}

class ClickListenerPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(
        dataSource: dataSource,
        theme: MapChartTheme(hoverColor: Colors.grey[800]!),
        clickListener: (feature) {
          print(feature.id);
        });
    return map;
  }
}
