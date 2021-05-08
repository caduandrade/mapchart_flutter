import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class GetStartedPage extends StatefulWidget {
  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(dataSource: dataSource);
    return map;
  }
}
