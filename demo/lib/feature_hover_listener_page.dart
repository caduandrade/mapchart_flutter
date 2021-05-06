import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class FeatureHoverListenerPage extends StatefulWidget {
  @override
  HoverListenerPageState createState() => HoverListenerPageState();
}

class HoverListenerPageState extends ExamplePageState {
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
        theme: MapChartTheme(hoverColor: Colors.grey[700]),
        hoverListener: (MapFeature? feature) {
          if (feature != null) {
            int id = feature.id;
            print('Hover - Feature id: $id');
          }
        });

    return map;
  }
}
