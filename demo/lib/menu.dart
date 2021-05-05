import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef WidgetBuilderUpdater = Function(WidgetBuilder widgetBuilder);

class MenuItem {
  MenuItem(this.name, this.builder);

  final String name;
  final WidgetBuilder builder;
}

class MenuWidget extends StatelessWidget {
  const MenuWidget(
      {Key? key, required this.widgetBuilderUpdater, required this.menuItems})
      : super(key: key);

  final WidgetBuilderUpdater widgetBuilderUpdater;
  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (MenuItem menuItem in menuItems) {
      children.add(_buildButton(menuItem));
    }
    return SingleChildScrollView(child: Column(children: children));
  }

  ElevatedButton _buildButton(MenuItem menuItem) {
    return ElevatedButton(
        onPressed: () => widgetBuilderUpdater(menuItem.builder),
        child: Text(menuItem.name));
  }
}