import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double size;

  const UnreadBadge({
    super.key,
    required this.count,
    required this.child,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFFE24B4A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: count > 9 ? 9 : 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
