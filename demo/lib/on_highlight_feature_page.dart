import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class OnHighlightFeaturePage extends StatefulWidget {
  @override
  OnHighlightFeaturePageState createState() => OnHighlightFeaturePageState();
}

class OnHighlightFeaturePageState extends ExamplePageState {
  MapChartDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _loadDataSource(geojson);
  }

  _loadDataSource(String geojson) async {
    MapChartDataSource dataSource = await MapChartDataSource.fromGeoJSON(
        geojson: geojson, identifierField: "Id");

    setState(() {
      _dataSource = dataSource;
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    MapChart map = MapChart(
        dataSource: _dataSource,
        onHighlightFeature: (MapFeature? feature) {
          if (feature != null) {
            int id = feature.id;
            print('Highlighted feature id: $id');
          } else {
            print('No highlighted feature');
          }
        });

    return map;
  }
}
