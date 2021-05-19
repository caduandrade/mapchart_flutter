import 'package:demo/menu.dart';
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';

import 'example_page.dart';

class LabelPage extends StatefulWidget {
  @override
  LabelPageState createState() => LabelPageState();
}

class LabelPageState extends ExamplePageState {
  @override
  Future<MapChartDataSource> loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.geoJSON(geojson: geojson, labelKey: 'Name');
    return dataSource;
  }

  List<MenuItem> buildMenuItems() {
    return [
      MenuItem('All visible', _allVisible),
      MenuItem('Visible rule', _visibleRule),
      MenuItem('Label style', _labelStyle)
    ];
  }

  Widget _allVisible() {
    MapChart map =
        MapChart(dataSource: dataSource, labelVisibility: (feature) => true);

    return map;
  }

  Widget _visibleRule() {
    MapChart map = MapChart(
        dataSource: dataSource,
        labelVisibility: (feature) => feature.label == 'Darwin');

    return map;
  }

  Widget _labelStyle() {
    MapChart map = MapChart(
        dataSource: dataSource,
        labelVisibility: (feature) => true,
    theme: MapChartTheme(labelStyleBuilder: (feature, featureColor, labelColor, hover) {
     if(feature.label=='Darwin'){
       return TextStyle(
         color: labelColor,
         fontWeight: FontWeight.bold,
         fontSize: 11,
       );
     }
     if(hover){
       return TextStyle(
         color: labelColor,
         decoration: TextDecoration.underline,
         fontSize: 11,
       );
     }
     return TextStyle(
       color: labelColor,
       fontSize: 11,
     );
    }));

    return map;
  }
}
