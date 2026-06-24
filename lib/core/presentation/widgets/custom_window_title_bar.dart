import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class CustomWindowTitleBar extends StatelessWidget {
  const CustomWindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Custom sharp colors for the system buttons window controls
    final buttonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.onSurface,
      mouseOver: theme.colorScheme.surfaceContainerHigh,
      mouseDown: theme.colorScheme.surfaceContainerHighest,
      iconMouseOver: theme.colorScheme.primary,
      iconMouseDown: theme.colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: theme.colorScheme.onSurface,
      iconMouseOver: Colors.white,
    );

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      height: 32,
      child: MoveWindow(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                'YOUTUBE VIDEO DOWNLOADER BY JESIE GAPOL',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
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
