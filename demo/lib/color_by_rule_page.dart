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
        geojson: geojson, keys: ['Name', 'Seq']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChartTheme theme = MapChartTheme.rule(
        contourColor: Colors.white,
        hoverColor: Colors.grey[700]!,
        colorRules: [
          (feature) {
            String? value = feature.getValue('Name');
            return value == 'Faraday' ? Colors.red : null;
          },
          (feature) {
            double? value = feature.getDoubleValue('Seq');
            return value != null && value < 3 ? Colors.green : null;
          },
          (feature) {
            double? value = feature.getDoubleValue('Seq');
            return value != null && value > 9 ? Colors.blue : null;
          }
        ]);

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }
}
