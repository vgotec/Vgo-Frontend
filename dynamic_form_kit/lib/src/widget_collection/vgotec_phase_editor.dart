// lib/presentation/widgets/widget_collection/vgotec_phase_editor.dart

import 'package:flutter/material.dart';

class VgotecPhaseEditor extends StatelessWidget {
  // Data
  final List<String> currentPhases;
  final List<String> removedPhases;
  final TextEditingController textController;
  
  // Callbacks
  final VoidCallback onAddPhase;
  final Function(String) onRemovePhase;
  final Function(String) onReAddPhase;
  final Function(int, int) onReorder;
  
  // Text
  final String label;
  final String addPhaseLabel;
  
  // Behavior
  final bool listShrinkWrap;
  final ScrollPhysics listPhysics;
  final bool showDragHandle;
  final bool showDeleteIcon;
  
  // Placement
  final double labelPaddingBottom;
  final double maxHeight;
  final double listPadding;
  final double cardMarginVertical;
  final double cardElevation;
  final double removedPillSpacing;
  final double removedPillRunSpacing;
  
  // Style
  final Color labelColor;
  final Color pillBackgroundColor;
  final Color pillTextColor;
  final Color pillIconColor;
  final Color dragHandleColor;
  final Color deleteIconColor;
  final Color addIconColor;

  const VgotecPhaseEditor({
    Key? key,
    required this.currentPhases,
    required this.removedPhases,
    required this.textController,
    required this.onAddPhase,
    required this.onRemovePhase,
    required this.onReAddPhase,
    required this.onReorder,
    required this.label,
    required this.addPhaseLabel,
    this.listShrinkWrap = true,
    this.listPhysics = const NeverScrollableScrollPhysics(),
    this.showDragHandle = true,
    this.showDeleteIcon = true,
    this.labelPaddingBottom = 12.0,
    this.maxHeight = 250.0,
    this.listPadding = 8.0,
    this.cardMarginVertical = 4.0,
    this.cardElevation = 1.0,
    this.removedPillSpacing = 8.0,
    this.removedPillRunSpacing = 4.0,
    this.labelColor = Colors.black,
    this.pillBackgroundColor = Colors.blue,
    this.pillTextColor = Colors.white,
    this.pillIconColor = Colors.white,
    this.dragHandleColor = Colors.grey,
    this.deleteIconColor = Colors.red,
    this.addIconColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Label
        Padding(
          padding: EdgeInsets.only(bottom: labelPaddingBottom),
          child: Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        
        // 2. The Reorderable List Box
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: LimitedBox(
            maxHeight: maxHeight,
            child: ReorderableListView(
              shrinkWrap: listShrinkWrap,
              physics: listPhysics,
              padding: EdgeInsets.all(listPadding),
              children: currentPhases.map((phase) {
                return Card(
                  key: ValueKey(phase),
                  margin: EdgeInsets.symmetric(vertical: cardMarginVertical),
                  elevation: cardElevation,
                  child: ListTile(
                    title: Text(phase),
                    leading: showDragHandle 
                      ? Icon(Icons.drag_handle, color: dragHandleColor) 
                      : null,
                    trailing: showDeleteIcon 
                      ? IconButton(
                          icon: Icon(Icons.delete_outline, color: deleteIconColor),
                          onPressed: () => onRemovePhase(phase),
                        )
                      : null,
                  ),
                );
              }).toList(),
              onReorder: onReorder,
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // 3. The "Removed Default Phases" (Pills)
        if (removedPhases.isNotEmpty)
          Wrap(
            spacing: removedPillSpacing,
            runSpacing: removedPillRunSpacing,
            children: removedPhases.map((phase) {
              return Chip(
                label: Text(phase),
                labelStyle: TextStyle(color: pillTextColor),
                backgroundColor: pillBackgroundColor,
                onDeleted: () => onReAddPhase(phase),
                deleteIcon: Icon(Icons.add_circle, size: 18, color: pillIconColor),
              );
            }).toList(),
          ),

        // 4. The custom text input field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: addPhaseLabel,
                  border: const OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) => onAddPhase(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: addIconColor, size: 30),
              onPressed: onAddPhase,
            ),
          ],
        ),
      ],
    );
  }
}