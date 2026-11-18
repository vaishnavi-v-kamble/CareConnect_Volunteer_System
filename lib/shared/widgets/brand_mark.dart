
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final bool showTagline;
  final bool light;
  final double iconSize;

  const BrandMark({
    super.key,
    this.showTagline = true,
    this.light = false,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : AppColors.navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: 0.16)
                : AppColors.mint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.volunteer_activism_rounded,
            color: light ? Colors.white : AppColors.teal,
            size: iconSize * 0.58,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CareConnect',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (showTagline)
                Text(
                  'Connecting Hearts, Changing Lives.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: light
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
