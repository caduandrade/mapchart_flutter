import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class FeatureHoverListenerPage extends StatefulWidget {
  @override
  FeatureHoverListenerPageState createState() =>
      FeatureHoverListenerPageState();
}

class FeatureHoverListenerPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChart map = MapChart(
        dataSource: dataSource,
        featureHoverListener: (MapFeature? feature) {
          if (feature != null) {
            int id = feature.id;
            print('Hover - Feature id: $id');
          }
        });

    return map;
  }
}
