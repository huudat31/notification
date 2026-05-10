import 'package:flutter/material.dart';

class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);
    final highlightColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFF2F2F7);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final color = Color.lerp(baseColor, highlightColor, _anim.value)!;
        return SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _ShimmerBox(width: 44, height: 44, radius: 22, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShimmerBox(
                        width: double.infinity,
                        height: 13,
                        radius: 4,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      _ShimmerBox(
                        width: 160,
                        height: 11,
                        radius: 4,
                        color: color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Timestamp placeholder
                _ShimmerBox(width: 40, height: 10, radius: 4, color: color),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
