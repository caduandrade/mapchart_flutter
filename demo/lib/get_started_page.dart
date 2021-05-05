import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class GetStartedPage extends StatefulWidget {
  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends ExamplePageState {
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
    if (_dataSource != null) {
      return Container(
          child: MapChart(dataSource: _dataSource!),
          decoration: BoxDecoration(border: Border.all()),
          padding: EdgeInsets.all(16));
    }
    return Text('Loading...');
  }
}
