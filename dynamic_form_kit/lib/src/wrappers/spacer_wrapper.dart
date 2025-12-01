// lib/presentation/widgets/dynamic_form/wrappers/spacer_wrapper.dart

import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:flutter/material.dart';


class SpacerWrapper extends StatelessWidget {
  final Map<String, dynamic> field;

  const SpacerWrapper({Key? key, required this.field}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final placement = config['placement'] as Map<String, dynamic>? ?? {};

    final double width = StyleParser.parseDouble(placement['width'], 0.0);
    final double height = StyleParser.parseDouble(placement['height'], 0.0);

    return SizedBox(width: width, height: height);
  }
}