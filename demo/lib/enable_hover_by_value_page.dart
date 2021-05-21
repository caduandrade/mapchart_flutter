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
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    // coloring only the 'Darwin' feature
    MapChartTheme theme =
        MapChartTheme.value(key: 'Seq', colors: {4: Colors.green});
    MapChartTheme hoverTheme = MapChartTheme(color: Colors.green[900]!);

    // enabling hover only for the 'Darwin' feature
    MapChart map = MapChart(
      dataSource: dataSource,
      theme: theme,
      hoverTheme: hoverTheme,
      hoverRule: (feature) {
        return feature.getValue('Seq') == 4;
      },
    );

    return map;
  }
}
