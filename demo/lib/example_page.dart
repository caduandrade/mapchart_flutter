import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'menu.dart';

abstract class ExamplePageState extends State<StatefulWidget> {
  late List<MenuItem> _menuItems;
  WidgetBuilder? _currentBuilder;

  late MultiSplitViewController _horizontalController;
  late MultiSplitViewController _verticalController;

  late String geojson;

  @override
  void initState() {
    super.initState();
    _horizontalController = MultiSplitViewController(weights: [.1, .8, .1]);
    _verticalController = MultiSplitViewController(weights: [.1, .8, .1]);
    _menuItems = buildMenuItems();
    if (_menuItems.isNotEmpty) {
      _currentBuilder = _menuItems.first.builder;
    }
    MapChartDemoPageState? state =
        context.findAncestorStateOfType<MapChartDemoPageState>();
    geojson = state!.geojson!;
  }

  _updateWidgetBuilder(WidgetBuilder widgetBuilder) {
    setState(() {
      _currentBuilder = widgetBuilder;
    });
  }

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(key:UniqueKey(),body: Center(child: buildContent(context)));

    MaterialApp materialApp = MaterialApp(
        theme: buildThemeData(),
        debugShowCheckedModeBanner: false,
        home: scaffold);

    MultiSplitView horizontal = MultiSplitView(
        dividerThickness: 20,
        children: [_buildEmptyArea(), materialApp, _buildEmptyArea()],
        minimalWeight: .1,
        controller: _horizontalController);

    MultiSplitView vertical = MultiSplitView(
        axis: Axis.vertical,
        dividerThickness: 20,
        children: [_buildEmptyArea(), horizontal, _buildEmptyArea()],
        minimalWeight: .1,
        controller: _verticalController);

    SizedBox sizedBox = SizedBox(child: vertical, width: 590, height: 412);
    Center center = Center(child: sizedBox);

    Widget contentMenu = Container(
      child: MenuWidget(
          widgetBuilderUpdater: _updateWidgetBuilder, menuItems: _menuItems),
      padding: EdgeInsets.all(8),
      decoration:
          BoxDecoration(border: Border(left: BorderSide(color: Colors.blue))),
    );

    Row row = Row(children: [Expanded(child: center), contentMenu]);
    return Container(child: row, color: Colors.white);
  }

  Widget _buildEmptyArea() {
    return Container(color: Colors.white);
  }

  ThemeData? buildThemeData() {
    return ThemeData(scaffoldBackgroundColor: Colors.white);
  }

  List<MenuItem> buildMenuItems() {
    return [];
  }

  Widget buildContent(BuildContext context) {
    if (_currentBuilder != null) {
      return _currentBuilder!(context);
    }
    return Center();
  }
}
