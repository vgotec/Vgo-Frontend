import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/wrappers/LeaveKpiWrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/LineChartWrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/calendar_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/details_view_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/gauge_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/hours_display_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/icon_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/readonly_label_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/stacked_bar_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/table_wrapper.dart';
import 'package:dynamic_form_kit/src/wrappers/time_picker_wrapper.dart';
import 'package:flutter/material.dart';
import '../wrappers/date_wrapper.dart';
import '../wrappers/dropdown_wrapper.dart';
import '../wrappers/text_wrapper.dart';
import '../wrappers/multiselect_wrapper.dart';
import '../wrappers/phase_editor_wrapper.dart';
import '../wrappers/button_wrapper.dart';
import '../wrappers/spacer_wrapper.dart';

class WidgetFactory {
  /// ✅ Now accepts an optional [dataContext]
  static Widget buildWidget(
    Map<String, dynamic> field,
    FormStateManager manager, {
    Map<String, dynamic>? dataContext, // This parameter is fine
  }) {
    final String type = field['type'] ?? 'text';

    switch (type) {
      case 'text':
      case 'textarea':
        return TextWrapper(field: field, manager: manager);

      case 'multiselect':
        return MultiSelectWrapper(field: field, manager: manager);

      case 'phase_editor':
        return PhaseEditorWrapper(field: field, manager: manager);

      case 'button':
        return ButtonWrapper(field: field, manager: manager);

      case 'spacer':
        return SpacerWrapper(field: field);

      case 'date':
        return DateWrapper(field: field, manager: manager);

      case 'dropdown':
        return DropdownWrapper(field: field, manager: manager);

      case 'hours_label':
        return HoursLabelWrapper(field: field, manager: manager);

      case 'time_picker':
        return TimePickerWrapper(field: field, manager: manager);

      case 'readonly_label':
        return ReadOnlyLabelWrapper(field: field, manager: manager);

      case 'calendar':
        return CalendarWrapper(
          field: field,
          manager: manager,
          dataContext: dataContext,
        );

      case 'icon':
        return IconWrapper(field: field, manager: manager);

      case 'table':
        return VgotecTableWrapper(
          config: field,
          manager: manager,
          onChanged: (data) {
            manager.setFieldValue(field['key'] ?? '', data);
          },
        );
      case 'details_view':
        return DetailsViewWrapper(
          field: field,
          manager: manager,
          dataContext: dataContext,
        );

      case 'stacked_bar':
      case 'STACKED_BAR': // accept both
        return StackedBarWrapper(
          field: field,
          manager: manager,
          dataContext: dataContext,
        );
      case "leave":
      case "line_chart":
        return LineChartWrapper(field: field, manager: manager);

      case "leaveKpi":
      case "kpi_card_group":
        return LeaveKpiWrapper(field: field, manager: manager);

      case "gauge":
      case "GAUGE":
        return GaugeWrapper(
          field: field,
          manager: manager,
          dataContext: dataContext,
        );

      default:
        return Text('Unsupported widget type: $type');
    }
  }
}
