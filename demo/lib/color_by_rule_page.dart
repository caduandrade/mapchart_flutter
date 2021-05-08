import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ColorByRulePage extends StatefulWidget {
  @override
  ColorByRulePageState createState() => ColorByRulePageState();
}

class ColorByRulePageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource = await MapChartDataSource.geoJSON(
        geojson: geojson, valueKeys: ['Distance']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChartTheme theme = MapChartTheme.rule(
        contourColor: Colors.white,
        hoverColor: Colors.grey[700]!,
        colorRules: [
          (feature) {
            return feature.getValue('Distance') < 100000000
                ? Colors.green
                : null;
          },
          (feature) {
            return feature.getValue('Distance') < 200000000
                ? Colors.blue
                : null;
          }
        ]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }
}
