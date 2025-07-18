import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatbot/theme/app_theme.dart';

class WaitingMessage extends StatelessWidget {
  const WaitingMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAIAvatar(),
          const SizedBox(width: 8),
          _buildTypingBubble(context, isDark),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutQuart)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.aiMessageGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble(BuildContext context, bool isDark) {
    final bubbleColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final dotColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTypingDot(dotColor, 0),
          const SizedBox(width: 4),
          _buildTypingDot(dotColor, 200),
          const SizedBox(width: 4),
          _buildTypingDot(dotColor, 400),
        ],
      ),
    );
  }

  Widget _buildTypingDot(Color color, int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat()).scaleXY(
          begin: 0.8,
          end: 1.2,
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeInOut,
        );
  }
}
