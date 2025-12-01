import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
import 'json_app_bar_wrapper.dart';
import 'json_drawer_wrapper.dart';
// Your modified DynamicFormRenderer is imported by dynamic_form_kit.dart

class JsonScaffoldWrapper extends StatelessWidget {
  final Map<String, dynamic> screenJson;
  final FormStateManager manager;

  const JsonScaffoldWrapper({
    super.key,
    required this.screenJson,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    // Read the main sections of the screen JSON
    final Map<String, dynamic>? appBarConfig = screenJson['appBar'];
    final Map<String, dynamic>? drawerConfig = screenJson['drawer'];
    final Map<String, dynamic>? bodyConfig = screenJson['body'];

    return Scaffold(
      // 1. If 'appBar' config exists, build it.
      appBar: appBarConfig != null
          ? JsonAppBarWrapper(
              config: appBarConfig,
              manager: manager,
            )
          : null,

      // 2. If 'drawer' config exists, build it.
      drawer: drawerConfig != null
          ? JsonDrawerWrapper(
              config: drawerConfig,
              manager: manager,
            )
          : null,

      // 3. Use your DynamicFormRenderer to build the body
      body: bodyConfig != null
          ? DynamicFormRenderer(
              formDefinition: bodyConfig, // bodyConfig is your old form JSON
              manager: manager,
              // Pass the manager's context down
              dataContext: manager.dataContext, 
            )
          : const Center(child: Text("No 'body' configured in JSON.")),
    );
  }
}