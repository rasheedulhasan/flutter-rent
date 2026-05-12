import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';

/// Pagination bar widget for navigating through pages.
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(
            icon: Icons.chevron_left_rounded,
            onTap: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          ...List.generate(totalPages, (index) {
            final isActive = index == currentPage;
            return GestureDetector(
              onTap: () => onPageChanged(index),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary
                      : isDark
                          ? AppTheme.surfaceDark
                          : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive
                      ? null
                      : Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          _PageButton(
            icon: Icons.chevron_right_rounded,
            onTap: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _PageButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight)
              : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
        ),
      ),
    );
  }
}
