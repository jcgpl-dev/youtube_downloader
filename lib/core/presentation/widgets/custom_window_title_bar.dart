import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomWindowTitleBar extends StatelessWidget {
  const CustomWindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.onSurfaceVariant,
      mouseOver: theme.colorScheme.surfaceContainerHigh,
      mouseDown: theme.colorScheme.surfaceContainerHighest,
      iconMouseOver: theme.colorScheme.primary,
      iconMouseDown: theme.colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: AppColors.error,
      mouseDown: AppColors.primaryDark,
      iconNormal: theme.colorScheme.onSurfaceVariant,
      iconMouseOver: theme.colorScheme.onSurface,
    );

    return Container(
      color: theme.colorScheme.surface,
      height: 32,
      child: MoveWindow(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Row(
              children: [
                MinimizeWindowButton(colors: buttonColors),
                MaximizeWindowButton(colors: buttonColors),
                CloseWindowButton(colors: closeButtonColors),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
