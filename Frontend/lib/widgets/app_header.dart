import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_colors.dart';
import '../providers/app_state.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showTimer;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showTimer = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isRoleAdmin = state.role == UserRole.admin;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Brand Logo & Title
          InkWell(
            onTap: () {
              if (state.role == UserRole.admin) {
                state.navigateTo(ActiveScreen.adminExamList);
              } else {
                state.navigateTo(ActiveScreen.studentExamList);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOEIC MASTER',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Reading Assessment',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Breadcrumb / Title
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Timer if active
          if (showTimer) ...[
            Consumer<AppState>(
              builder: (context, appState, child) {
                int secs = appState.remainingSeconds;
                bool isUrgent = secs <= 300; // <= 5 mins

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.accentRedBg : AppColors.accentGreenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUrgent ? AppColors.accentRed : AppColors.primaryTeal,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: isUrgent ? AppColors.accentRed : AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(secs),
                        style: TextStyle(
                          color: isUrgent ? AppColors.accentRed : AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
          ],

          // Role Switcher Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoleButton(
                  context: context,
                  label: 'Giảng viên',
                  icon: Icons.admin_panel_settings_rounded,
                  isSelected: isRoleAdmin,
                  onTap: () => state.setRole(UserRole.admin),
                ),
                _buildRoleButton(
                  context: context,
                  label: 'Thí sinh',
                  icon: Icons.person_rounded,
                  isSelected: !isRoleAdmin,
                  onTap: () => state.setRole(UserRole.candidate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
