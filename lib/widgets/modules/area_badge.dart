import 'package:flutter/material.dart';

class AreaBadge extends StatelessWidget {
  final String area;

  const AreaBadge({
    super.key,
    required this.area,
  });

  Map<String, Map<String, Color>> get areaStyles => {
        'Físico-Matemáticas y Ciencias de la Tierra': {
          'dot': const Color(0xFF1565C0),
          'bg': const Color(0xFFEAF3FF),
          'text': const Color(0xFF1E3A8A),
        },

        'Biología y Química': {
          'dot': const Color(0xFF22B8CF),
          'bg': const Color(0xFFE8FAFD),
          'text': const Color(0xFF0B7285),
        },

        'Medicina y Ciencias de la Salud': {
          'dot': const Color(0xFF2563EB),
          'bg': const Color(0xFFEAF1FF),
          'text': const Color(0xFF1D4ED8),
        },

        'Humanidades y Ciencias de la Conducta': {
          'dot': const Color(0xFFEC4899),
          'bg': const Color(0xFFFDEBF4),
          'text': const Color(0xFFBE185D),
        },

        'Ciencias Sociales': {
          'dot': const Color(0xFF16A34A),
          'bg': const Color(0xFFEAF8EF),
          'text': const Color(0xFF166534),
        },

        'Biotecnología y Ciencias Agropecuarias': {
          'dot': const Color(0xFFF59E0B),
          'bg': const Color(0xFFFFF7E6),
          'text': const Color(0xFFB45309),
        },

        'Ingenierías': {
          'dot': const Color(0xFF8B5CF6),
          'bg': const Color(0xFFF3EEFF),
          'text': const Color(0xFF6D28D9),
        },

        'Artes': {
          'dot': const Color(0xFF7C3AED),
          'bg': const Color(0xFFF4EEFF),
          'text': const Color(0xFF6D28D9),
        },
      };

  @override
  Widget build(BuildContext context) {
    final style = areaStyles[area] ??
        {
          'dot': const Color(0xFF9CA3AF),
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF374151),
        };

    return Container(
      constraints: const BoxConstraints(
        minWidth: 140,
        maxWidth: 160,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: style['bg'],
        borderRadius: BorderRadius.circular(10),
      ),

      child: Text(
        area,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: style['text'],
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
          height: 1.3,
        ),
      ),
    );
  }
}