import 'package:demo/color_by_id_page.dart';
import 'package:demo/contour_page.dart';
import 'package:demo/enable_hover_by_id_page.dart';
import 'package:demo/get_started_page.dart';
import 'package:demo/feature_hover_listener_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'default_colors_page.dart';
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
  ContentBuilder? _currentExampleBuilder;
  String? geojson;

  @override
  void initState() {
    super.initState();
    _menuItems = [
      MenuItem('Get Started', _getStartedPage),
      MenuItem('Color by id', _colorByIdPage),
      MenuItem('Default colors', _defaultColorsPage),
      MenuItem('Contour', _contourPage),
      MenuItem('Hover listener', _hoverListenerPage),
      MenuItem('Enable hover by id', _enableHoverByIdPage)
    ];
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
          contentBuilderUpdater: _updateExampleContentBuilder,
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
          children: [exampleMenu, Expanded(child: _buildExample())],
          crossAxisAlignment: CrossAxisAlignment.stretch);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('MapChart Demo'),
        ),
        body: body);
  }

  _updateExampleContentBuilder(ContentBuilder contentBuilder) {
    setState(() {
      _currentExampleBuilder = contentBuilder;
    });
  }

  Widget _buildExample() {
    if (_currentExampleBuilder != null) {
      return _currentExampleBuilder!();
    }
    return Center();
  }

  GetStartedPage _getStartedPage() {
    return GetStartedPage();
  }

  ColorByIdPage _colorByIdPage() {
    return ColorByIdPage();
  }

  DefaultColorsPage _defaultColorsPage() {
    return DefaultColorsPage();
  }

  ContourPage _contourPage() {
    return ContourPage();
  }

  FeatureHoverListenerPage _hoverListenerPage() {
    return FeatureHoverListenerPage();
  }

  EnableHoverByIdPage _enableHoverByIdPage() {
    return EnableHoverByIdPage();
  }
}
