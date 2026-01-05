import 'package:flutter/material.dart';

class BotaoCalculadora extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const BotaoCalculadora({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
    );
  }
}
