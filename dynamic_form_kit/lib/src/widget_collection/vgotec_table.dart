import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';

class VgotecTable extends StatefulWidget {
  final String label;
  final List<Map<String, dynamic>> columns;
  final List<Map<String, dynamic>> rows;
  final Color borderColor;
  final Color headerColor;
  final Color textColor;
  final double borderWidth;
  final Function(List<Map<String, dynamic>>) onChanged;
  final FormStateManager manager;
  final String dataKey;

  const VgotecTable({
    Key? key,
    required this.label,
    required this.columns,
    required this.rows,
    required this.borderColor,
    required this.headerColor,
    required this.textColor,
    required this.borderWidth,
    required this.onChanged,
    required this.manager,
    required this.dataKey,
  }) : super(key: key);

  @override
  State<VgotecTable> createState() => _VgotecTableState();
}

class _VgotecTableState extends State<VgotecTable> {
  late List<double> columnWidths;
  late List<Map<String, dynamic>> displayRows;

  @override
  void initState() {
    super.initState();
    displayRows = List.from(widget.rows);
    columnWidths = List.generate(widget.columns.length, (_) => 150);
    widget.manager.addListener(_onManagerUpdate);
  }

  @override
  void didUpdateWidget(covariant VgotecTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      setState(() => displayRows = List.from(widget.rows));
    }
  }

  void _onManagerUpdate() {
    final dynamic newData = widget.manager.dataContext[widget.dataKey];
    if (newData is List) {
      setState(() {
        displayRows = List<Map<String, dynamic>>.from(newData);
      });
    }
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerUpdate);
    super.dispose();
  }

  IconData _getIconByName(String name) {
    switch (name) {
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'add':
        return Icons.add;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.circle;
    }
  }

  Widget _buildCell(Map<String, dynamic> column, Map<String, dynamic> row) {
    final String key = column['key'] ?? '';
    final String type = column['type'] ?? 'text';
    final dynamic value = row[key];
    final String? tooltip = column['tooltip']?.toString();
    final tooltipText = tooltip ?? ((value?.toString().length ?? 0) > 20 ? value.toString() : '');

    Widget child;
    switch (type) {
      case 'icon':
        final iconName = column['icon'] ?? 'info';
        child = Icon(_getIconByName(iconName), color: Colors.blueGrey);
        break;
      case 'checkbox':
        child = Icon(
          (value == true || value == "true")
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          color: Colors.blueGrey,
        );
        break;
      default:
        child = Text(
          value?.toString() ?? '',
          style: TextStyle(color: widget.textColor),
          overflow: TextOverflow.ellipsis,
        );
    }

    return Tooltip(
      message: tooltipText,
      waitDuration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Detect if actions column exists
    final actionsColumn = widget.columns.firstWhere(
      (col) => col['key'] == 'actions' && col['type'] == 'actions',
      orElse: () => {},
    );
    final hasActionsColumn = actionsColumn.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.borderColor.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ---------- HEADER ----------
              Container(
                decoration: BoxDecoration(
                  color: widget.headerColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < widget.columns.length; i++)
                      if (widget.columns[i]['key'] != 'actions')
                        Container(
                          width: columnWidths[i],
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            widget.columns[i]['label'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                    if (hasActionsColumn)
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "Actions",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- DATA ROWS ----------
              for (int i = 0; i < displayRows.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: widget.borderColor.withOpacity(0.3),
                        width: widget.borderWidth,
                      ),
                    ),
                    color: i.isEven ? Colors.grey.shade50 : Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int j = 0; j < widget.columns.length; j++)
                          if (widget.columns[j]['key'] != 'actions')
                            SizedBox(
                              width: columnWidths[j],
                              child: _buildCell(widget.columns[j], displayRows[i]),
                            ),

                        if (hasActionsColumn)
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final iconConf in (actionsColumn['icons'] ?? []))
                                  IconButton(
                                    icon: Icon(
                                      _getIconByName(iconConf['name']),
                                      color: Color(_parseColor(iconConf['color'] ?? "#000000")),
                                    ),
                                    tooltip: iconConf['tooltip'] ?? '',
                                    
                                    // ⭐️⭐️⭐️ KEY CHANGE IS HERE ⭐️⭐️⭐️
                                    onPressed: () {
                                      // 1. Get the action from JSON
                                      final action = iconConf['action'] as Map<String, dynamic>? ?? {};
                                      final actionType = action['type'] as String?;
                                      
                                      // 2. Get the payload from JSON (e.g., {"endpoint": "..."})
                                      final jsonPayload = action['payload'] as Map<String, dynamic>? ?? {};

                                      // 3. Get the data for the specific row (e.g., {"id": "123", ...})
                                      final rowData = Map<String, dynamic>.from(displayRows[i]);

                                      // 4. Merge them. Row data + JSON payload.
                                      //    The handler will get {'id': '123', 'endpoint': '...'}
                                      final finalPayload = rowData..addAll(jsonPayload);

                                      if (actionType != null) {
                                        widget.manager.dispatchAction(
                                          actionType,
                                          payload: finalPayload, // 5. Dispatch the merged payload
                                        );
                                      } else {
                                        debugPrint("VgotecTable: Icon action has no 'type'");
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int _parseColor(String colorString) {
    String hex = colorString.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return int.parse(hex, radix: 16);
  }
}