import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';

/// Horizontal scrollable tab selector for filtering.
class TabSelector extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab == selectedTab;
          return GestureDetector(
            onTap: () => onTabChanged(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : isDark
                        ? AppTheme.surfaceDark
                        : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      ),
              ),
              child: Center(
                child: Text(
                  tab[0].toUpperCase() + tab.substring(1),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
