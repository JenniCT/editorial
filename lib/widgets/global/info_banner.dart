import 'package:flutter/cupertino.dart';

enum BannerType { info, warning, error, success }

class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final bool compact;
  final IconData? icon;

  const InfoBanner({
    super.key,
    required this.message,
    this.type    = BannerType.info,
    this.compact = false,
    this.icon,
  });

  static const _tokens = {
    BannerType.info: (
      bg:     Color(0xFFEFF6FF),
      border: Color(0xFFBFDBFE),
      text:   Color(0xFF1D4ED8),
      icon:   CupertinoIcons.info_circle_fill,
    ),
    BannerType.warning: (
      bg:     Color(0xFFFFFBEB),
      border: Color(0xFFFDE68A),
      text:   Color(0xFFB45309),
      icon:   CupertinoIcons.exclamationmark_triangle_fill,
    ),
    BannerType.error: (
      bg:     Color(0xFFFFF3F3),
      border: Color(0xFFFECACA),
      text:   Color(0xFFDC2626),
      icon:   CupertinoIcons.xmark_circle_fill,
    ),
    BannerType.success: (
      bg:     Color(0xFFF0FFF4),
      border: Color(0xFFBBF7D0),
      text:   Color(0xFF15803D),
      icon:   CupertinoIcons.checkmark_circle_fill,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = _tokens[type]!;

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(compact ? 7 : 9),
        border: Border.all(color: t.border),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(icon ?? t.icon, size: compact ? 12 : 14, color: t.text),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize:   compact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color:      t.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}