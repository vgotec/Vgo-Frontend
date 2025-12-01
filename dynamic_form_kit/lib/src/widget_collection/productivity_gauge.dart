import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ProductivityGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final List<Color> rangeColors;
  final Map<String, dynamic> chartOptions;
  final Map<String, dynamic> data;

  const ProductivityGauge({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.rangeColors,
    required this.chartOptions,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: animationDuration must be a double for SfRadialGauge
    final animationDuration = (chartOptions['animationDuration'] as num? ?? 1500).toDouble(); 
    final startAngle = (chartOptions['gaugeStartAngle'] as num? ?? 180).toDouble();
    final endAngle = (chartOptions['gaugeEndAngle'] as num? ?? 0).toDouble();
    
    // Ensure value is clamped between min and max
    final clampedValue = value.clamp(min, max);
    
    // Determine the color based on the current category
    final category = data['category']?.toString().toUpperCase() ?? 'LOW';
    Color needleColor = Colors.grey;
    if (category == 'LOW' && rangeColors.isNotEmpty) {
      needleColor = rangeColors[0];
    } else if (category == 'MEDIUM' && rangeColors.length > 1) {
      needleColor = rangeColors[1];
    } else if (category == 'HIGH' && rangeColors.length > 2) {
      needleColor = rangeColors[2];
    }

    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: animationDuration, // Now correctly a double
      axes: <RadialAxis>[
        RadialAxis(
          minimum: min,
          maximum: max,
          startAngle: startAngle,
          endAngle: endAngle,
          showLabels: false,
          showTicks: false,
          axisLineStyle: const AxisLineStyle(
            // FIX: thickness is renamed to thicknessFactor when using GaugeSizeUnit.factor
            thickness: 0.15,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.black12, // Base grey track
          ),
          
          // 1. Gauge Ranges (Colored background segments)
          ranges: _buildGaugeRanges(),

          // 2. Gauge Pointer (The Needle)
          pointers: <GaugePointer>[
            NeedlePointer(
              value: clampedValue,
              needleStartWidth: 1.0, // FIX: Must be double
              needleEndWidth: 5.0,   // FIX: Must be double
              needleColor: needleColor,
              knobStyle: KnobStyle(
                knobRadius: 0.08,
                color: needleColor,
                borderWidth: 0.02,
                borderColor: Colors.white,
                // FIX: thickness parameter was removed
              ),
              tailStyle: const TailStyle(
                width: 5.0, // FIX: Must be double
                length: 0.15,
                color: Colors.black12,
              ),
              enableAnimation: true,
            )
          ],

          // 3. Annotations (Value text in the center)
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 90, 
              positionFactor: 0.1,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${clampedValue.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: needleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
             // Optional: Display Expected Hours
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.7,
              widget: Text(
                'Expected: ${data['expectedHours']?.toStringAsFixed(0) ?? 'N/A'}h',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  List<GaugeRange> _buildGaugeRanges() {
    if (rangeColors.isEmpty) return [];

    final rangeCount = rangeColors.length;
    final rangeSize = (max - min) / rangeCount;
    final List<GaugeRange> ranges = [];
    
    for (int i = 0; i < rangeCount; i++) {
      ranges.add(
        GaugeRange(
          startValue: min + i * rangeSize,
          endValue: min + (i + 1) * rangeSize,
          color: rangeColors[i],
          startWidth: 0.15,
          endWidth: 0.15,
          sizeUnit: GaugeSizeUnit.factor,
        ),
      );
    }
    return ranges;
  }
}