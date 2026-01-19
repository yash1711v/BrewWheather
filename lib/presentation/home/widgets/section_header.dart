// lib/features/home/widgets/section_header_animated.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SectionHeader extends StatefulWidget {
  final String title;
  final VoidCallback? onDetailsTap;
  final IconData? icon;
  final String? actionText;

  const SectionHeader({
    super.key,
    required this.title,
    this.onDetailsTap,
    this.icon,
    this.actionText,
  });

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // Animated Icon Container
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueWithOpacity(0.15 * value),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlueWithOpacity(0.2 * value),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon ?? Icons.calendar_today,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Title with fade-in animation
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Animated Action Button
          if (widget.onDetailsTap != null)
            GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                widget.onDetailsTap?.call();
              },
              onTapCancel: () => _controller.reverse(),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovering
                              ? AppTheme.textPrimary.withOpacity(0.1)
                              : AppTheme.textPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isHovering
                                ? AppTheme.primaryBlueWithOpacity(0.3)
                                : AppTheme.textPrimary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.actionText ?? 'DETAILS',
                              style: TextStyle(
                                color: _isHovering
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textPrimary.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: _isHovering ? 0.125 : 0,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: _isHovering
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textPrimary.withOpacity(0.8),
                                size: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}