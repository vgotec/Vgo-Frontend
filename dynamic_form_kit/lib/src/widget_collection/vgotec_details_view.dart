// lib/presentation/widgets/dynamic_form/widget_collection/vgotec_details_view.dart

import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';

class DetailsViewItem {
  final String label;
  final String value;
  final IconData? icon;
  final bool multiline;
  final Map<String, dynamic> itemStyle;

  DetailsViewItem({
    required this.label,
    required this.value,
    this.icon,
    required this.multiline,
    required this.itemStyle,
  });
}

class VgotecDetailsView extends StatelessWidget {
  final List<DetailsViewItem> items;
  final String dividerType; // none | line | box
  final double spacing;
  final double columnGap;
  final Map<String, dynamic> globalStyle;

  const VgotecDetailsView({
    Key? key,
    required this.items,
    required this.dividerType,
    required this.spacing,
    required this.columnGap,
    required this.globalStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelColor =
        StyleParser.parseColor(globalStyle['labelColor'], Colors.black87);
    final valueColor =
        StyleParser.parseColor(globalStyle['valueColor'], Colors.black54);
    final labelSize =
        StyleParser.parseDouble(globalStyle['labelFontSize'], 14);
    final valueSize =
        StyleParser.parseDouble(globalStyle['valueFontSize'], 14);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - columnGap) / 2;

        final List<Widget> children = [];

        for (final item in items) {
          final style = item.itemStyle;

          final Color itemLabelColor =
              StyleParser.parseColor(style['labelColor'], labelColor);
          final Color itemValueColor =
              StyleParser.parseColor(style['valueColor'], valueColor);

          final double itemLabelSize =
              StyleParser.parseDouble(style['labelFontSize'], labelSize);
          final double itemValueSize =
              StyleParser.parseDouble(style['valueFontSize'], valueSize);

          Widget content = SizedBox(
            width: width,
            child: Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                crossAxisAlignment: item.multiline
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: itemLabelSize + 6, color: itemLabelColor),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: itemLabelSize,
                            fontWeight: FontWeight.w600,
                            color: itemLabelColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          maxLines: item.multiline ? null : 2,
                          overflow: item.multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: itemValueSize,
                            color: itemValueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          if (dividerType == "box") {
            content = Container(
              width: width,
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(bottom: spacing),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: content, // ✅ Correct widget
            );

          }

          children.add(content);
        }

        if (dividerType == "line") {
          final List<Widget> rows = [];

          for (int i = 0; i < children.length; i += 2) {
            final left = children[i];
            final right =
                (i + 1 < children.length) ? children[i + 1] : SizedBox(width: width);

            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                SizedBox(width: columnGap),
                right,
              ],
            ));

            if (i + 2 < children.length) {
              rows.add(Divider(height: 1, thickness: 1));
            }
          }

          return Column(children: rows);
        }

        return Wrap(
          spacing: columnGap,
          runSpacing: spacing,
          children: children,
        );
      },
    );
  }
}
