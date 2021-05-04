import 'package:flutter/cupertino.dart';
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
  MapChartTheme? _theme;

  @override
  void initState() {
    super.initState();
    String asset = 'geojson/brazil_uf.json';
    asset = 'geojson/example.json';
    rootBundle.loadString(asset).then((json) {
      _loadGeoJSON2(json);
    });
  }

  _loadGeoJSON(String json) async {
    MapGeometryReader reader = MapGeometryReader();
    List<MapGeometry> geometries = await reader.geoJSON(json);
    MapChartDataSource dataSource = MapChartDataSource.geometries(geometries);

    setState(() {
      _dataSource = dataSource;
    });
  }

  _loadGeoJSON2(String json) async {
    List<MapFeature> features = await MapFeatureReader.geoJSON(
        geojson: json,
        identifierField: "Id",
        nameField: "Name",
        valueFields: ["Distance"]);

    MapChartTheme theme = MapChartTheme(colors: {
      "earth": Colors.green,
      "mars": Colors.red,
      "venus": Colors.orange
    });

    MapChartDataSource dataSource = MapChartDataSource.features(features);

    setState(() {
      _dataSource = dataSource;
      _theme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource != null) {
      double divider = 10;

      Widget map = Container(
          child: MapChart(dataSource: _dataSource!, theme: _theme),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          padding: EdgeInsets.all(8));

      Widget mapArea = Padding(
        child: map,
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
