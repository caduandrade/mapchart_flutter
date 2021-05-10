import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class ColorByValuePage extends StatefulWidget {
  @override
  ColorByValuePageState createState() => ColorByValuePageState();
}

class ColorByValuePageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, keys: ['Seq']);
    return dataSource;
  }

  @override
  Widget buildContent() {
    MapChartTheme theme =
        MapChartTheme.value(contourColor: Colors.white, key: 'Seq', colors: {
      2: Colors.green,
      4: Colors.red,
      6: Colors.orange,
      8: Colors.blue
    }, hoverColors: {
      2: Colors.green[900]!,
      4: Colors.red[900]!,
      6: Colors.orange[900]!,
      8: Colors.blue[900]!
    });

    MapChart map = MapChart(dataSource: dataSource, theme: theme);

    return map;
  }
}
