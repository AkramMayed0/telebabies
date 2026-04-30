import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool fullScreen;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.fullScreen = false,
    this.size = 28,
  });

  const LoadingIndicator.fullScreen({super.key, this.message})
      : fullScreen = true,
        size = 28;

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: const AlwaysStoppedAnimation(TbColors.pink),
            backgroundColor: TbColors.pinkSoft,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: TbColors.ink3,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: TbColors.bg,
        body: Center(child: indicator),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: indicator,
      ),
    );
  }
}
