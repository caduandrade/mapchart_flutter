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

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('brazil_uf.json').then((geojson) {
      _loadDataSource(geojson);
    });
  }

  _loadDataSource(String geojson) async {
    MapChartDataSource dataSource =
        await MapChartDataSource.fromGeoJSON(geojson: geojson);
    setState(() {
      _dataSource = dataSource;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (_dataSource != null) {
      content = _buildMapContainer();
    } else {
      content = Text('Loading...');
    }

    MultiSplitView multiSplitView = MultiSplitView(
        children: [content, Container(width: 50)]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
              child: SizedBox(width: 600, height: 500, child: multiSplitView))),
    );
  }

  Widget _buildMapContainer() {
    return Container(
        child: MapChart(
            dataSource: _dataSource!,
            theme: MapChartTheme(
                color: Colors.green,
                contourColor: Colors.green[900],
                highlightColor: Colors.green[800])),
        decoration: BoxDecoration(border: Border.all()),
        padding: EdgeInsets.all(16));
  }
}
