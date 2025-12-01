// In your package: lib/src/wrappers/json_body_wrapper.dart

import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
// ⭐️ Import your LayoutParser and WidgetFactory
// import 'package:your_package_name/src/layout_parser.dart';
// import 'package:your_package_name/src/widget_factory.dart';

class JsonBodyWrapper extends StatelessWidget {
  final Map<String, dynamic> config;
  final FormStateManager manager;

  const JsonBodyWrapper({
    super.key,
    required this.config,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------
    // ⭐️ THIS IS WHERE I NEED YOUR HELP
    // -----------------------------------------------------------------
    // I am *assuming* your LayoutParser is a widget you can call,
    // and it handles the "rows" and "fields" itself.
    //
    // If your LayoutParser.build() returns a Widget, this is all you need:
    //
    // return LayoutParser.build(
    //   config: config,
    //   manager: manager,
    // );
    //
    // -----------------------------------------------------------------
    
    // For now, I'll provide a placeholder.
    // Replace this with the real call to your LayoutParser.
    return Center(
      child: Text("JsonBodyWrapper needs LayoutParser to be configured."),
    );
  }
}