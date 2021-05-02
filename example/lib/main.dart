import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:mapchart/mapchart.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() {
  runApp(ExampleWidget());
}

class ExampleWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  MapChartDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    String asset = 'geojson/brazil_uf.json';
    rootBundle.loadString(asset).then((json) {
      _loadMapChartDataSource(json);
    });
  }

  _loadMapChartDataSource(String geojson) async {
    List<MapGeometry> geometries = await MapGeometry.fromGeoJSON(geojson);
    MapChartDataSource dataSource = MapChartDataSource(geometries);

    setState(() {
      _dataSource = dataSource;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource != null) {
      double divider = 10;

      Widget mapArea = Padding(
        child: Container(
            child: MapChart(dataSource: _dataSource!),
            decoration: BoxDecoration(border: Border.all(color: Colors.black))),
        padding: EdgeInsets.fromLTRB(divider, divider, 0, divider),
      );
      Widget emptyArea = Container(color: Colors.white);

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: MultiSplitView(
                children: [mapArea, emptyArea], dividerThickness: divider)),
      );
    }
    return Center();
  }
}
