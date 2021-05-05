import 'package:demo/get_started_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu.dart';

void main() {
  runApp(MapChartApp());
}

class MapChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TabbedView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapChartDemoPage(),
    );
  }
}

class MapChartDemoPage extends StatefulWidget {
  @override
  MapChartDemoPageState createState() => MapChartDemoPageState();
}

class MapChartDemoPageState extends State<MapChartDemoPage> {
  late List<MenuItem> _menuItems;
  WidgetBuilder? _currentExampleBuilder;
  String? geojson;

  @override
  void initState() {
    super.initState();
    _menuItems = [MenuItem('Get Started', _getStartedPage)];
    if (_menuItems.isNotEmpty) {
      _currentExampleBuilder = _menuItems.first.builder;
    }
    rootBundle.loadString('example.json').then((json) {
      setState(() {
        geojson = json;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget exampleMenu = Container(
      child: MenuWidget(
          widgetBuilderUpdater: _updateExampleWidgetBuilder,
          menuItems: _menuItems),
      padding: EdgeInsets.all(8),
      decoration:
          BoxDecoration(border: Border(right: BorderSide(color: Colors.blue))),
    );

    Widget? body;
    if (geojson == null) {
      body = Center(child: Text('Loading...'));
    } else {
      body = Row(
          children: [exampleMenu, Expanded(child: _buildExample(context))],
          crossAxisAlignment: CrossAxisAlignment.stretch);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('MapChart Demo'),
        ),
        body: body);
  }

  _updateExampleWidgetBuilder(WidgetBuilder widgetBuilder) {
    setState(() {
      _currentExampleBuilder = widgetBuilder;
    });
  }

  Widget _buildExample(BuildContext context) {
    if (_currentExampleBuilder != null) {
      return _currentExampleBuilder!(context);
    }
    return Center();
  }

  GetStartedPage _getStartedPage(BuildContext context) {
    return GetStartedPage();
  }
}
