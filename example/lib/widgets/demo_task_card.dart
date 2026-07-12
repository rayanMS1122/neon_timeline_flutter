import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../models/demo_task.dart';

class DemoTaskCardContent extends StatelessWidget {
  const DemoTaskCardContent({
    required this.task,
    required this.details,
    super.key,
  });

  final DemoTask task;
  final NeonScheduleEntryDetails<DemoTask> details;

  @override
  Widget build(BuildContext context) {
    final overlap = details.overlapsPrevious || details.overlapsNext;
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: task.color.withOpacity(0.13),
            shape: BoxShape.circle,
            border: Border.all(color: task.color.withOpacity(0.28)),
          ),
          child: Icon(
            switch (task.status) {
              NeonTimelineStatus.completed => Icons.check_rounded,
              NeonTimelineStatus.error => Icons.priority_high_rounded,
              NeonTimelineStatus.disabled => Icons.lock_outline_rounded,
              _ => Icons.bolt_rounded,
            },
            color: task.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (!task.draggable)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.lock_outline_rounded, size: 14),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                task.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.58),
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
              if (overlap) ...<Widget>[
                const SizedBox(height: 7),
                Text(
                  'OVERLAP DETECTED',
                  style: TextStyle(
                    color: task.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
