import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  final Widget child;
  final double initialX;
  final double initialY;
  final void Function(double x, double y)? onPositionChanged;
  final List<Widget>? headerActions;

  const DraggableWidget({
    super.key,
    required this.child,
    this.initialX = 0,
    this.initialY = 0,
    this.onPositionChanged,
    this.headerActions,
  });

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late double xPosition;
  late double yPosition;

  @override
  void initState() {
    super.initState();
    xPosition = widget.initialX;
    yPosition = widget.initialY;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Drag handle and actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    xPosition = (xPosition + details.delta.dx).clamp(0.0, 2000.0);
                    yPosition = (yPosition + details.delta.dy).clamp(0.0, 4000.0);
                  });
                  widget.onPositionChanged?.call(xPosition, yPosition);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              if (widget.headerActions != null) ...widget.headerActions!,
            ],
          ),
          const SizedBox(height: 4),

          // Actual widget
          widget.child,
        ],
      ),
    );
  }
}