import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class OnHighlightFeaturePage extends StatefulWidget {
  @override
  OnHighlightFeaturePageState createState() => OnHighlightFeaturePageState();
}

class OnHighlightFeaturePageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  Widget buildContent(BuildContext context) {
    MapChart map = MapChart(
        dataSource: dataSource,
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
