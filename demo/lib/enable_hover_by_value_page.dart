import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class EnableHoverByValuePage extends StatefulWidget {
  @override
  EnableHoverByValuePageState createState() => EnableHoverByValuePageState();
}

class EnableHoverByValuePageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, valueKeys: ['Id']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    // coloring only the 'earth' feature
    MapChartTheme theme = MapChartTheme.value(
        key: 'Id',
        colors: {'earth': Colors.green},
        hoverColor: Colors.green[900]!);

    // enabling hover only for the 'earth' feature
    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverRule: (feature) {
        return feature.getValue('Id') == 'earth';
      },
    );

    return map;
  }
}
