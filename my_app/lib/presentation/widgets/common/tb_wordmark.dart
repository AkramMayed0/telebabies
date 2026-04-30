import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class TbLogo extends StatelessWidget {
  final double size;
  final Color color;
  final Color accent;

  const TbLogo({
    super.key,
    this.size = 28,
    this.color = TbColors.ink,
    this.accent = TbColors.pink,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TbLogoPainter(color: color, accent: accent),
    );
  }
}

class _TbLogoPainter extends CustomPainter {
  final Color color;
  final Color accent;
  const _TbLogoPainter({required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = accent);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(cx - r * 0.29, cy - r * 0.17), r * 0.13, dotPaint);
    canvas.drawCircle(Offset(cx + r * 0.29, cy - r * 0.17), r * 0.13, dotPaint);

    final smilePath = Path()
      ..moveTo(cx - r * 0.38, cy + r * 0.29)
      ..quadraticBezierTo(cx, cy + r * 0.71, cx + r * 0.38, cy + r * 0.29);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.15
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TbLogoPainter old) =>
      old.color != color || old.accent != accent;
}

class TbWordmark extends StatelessWidget {
  final String lang;
  final double size;
  final Color color;

  const TbWordmark({
    super.key,
    this.lang = 'ar',
    this.size = 22,
    this.color = TbColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TbLogo(size: size + 4, color: color),
        const SizedBox(width: 6),
        if (lang == 'ar') ...[
          Text(
            'تيلي',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          Text(
            'بيبيز',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: TbColors.pink,
              height: 1,
            ),
          ),
        ] else ...[
          Text(
            'tele',
            style: TextStyle(
              fontFamily: TbFonts.display,
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.4,
              height: 1,
            ),
          ),
          Text(
            'babies',
            style: TextStyle(
              fontFamily: TbFonts.display,
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: TbColors.pink,
              letterSpacing: -0.4,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}
