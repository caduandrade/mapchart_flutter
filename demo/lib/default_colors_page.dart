import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class DefaultColorsPage extends StatefulWidget {
  @override
  DefaultColorsPageState createState() => DefaultColorsPageState();
}

class DefaultColorsPageState extends ExamplePageState {
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
  Widget buildContent(BuildContext context) {
    MapChart map = MapChart(
        dataSource: _dataSource,
        theme: MapChartTheme(
            color: Colors.yellow,
            contourColor: Colors.red,
            highlightColor: Colors.orange));

    return map;
  }
}
