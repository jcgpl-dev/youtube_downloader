import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class AppBrandWidget extends StatelessWidget {
  final ThemeData theme;

  const AppBrandWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/app-ic.png',
          width: 30,
          height: 30,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharp',
                  style: AppTextStyles.brandTitle.copyWith(
                    fontSize: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tube',
                  style: AppTextStyles.brandTitle.copyWith(
                    fontSize: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              'VIDEO DOWNLOADER',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
