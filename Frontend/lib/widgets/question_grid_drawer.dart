import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_colors.dart';
import '../providers/app_state.dart';

class QuestionGridDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const QuestionGridDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final answeredCount = state.selectedAnswers.length;
    final totalCount = 100;
    final unAnsweredCount = totalCount - answeredCount;
    final flaggedCount = state.flaggedQuestions.length;

    return Container(
      width: 380,
      color: AppColors.surfaceWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng quan bài thi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Câu 101 – 200 (100 câu)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: onClose,
                    tooltip: 'Đóng',
                  ),
              ],
            ),
          ),

          // Progress Bar & Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppColors.bgLight,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ làm bài: $answeredCount/$totalCount',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${(answeredCount / totalCount * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: answeredCount / totalCount,
                    backgroundColor: AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem(AppColors.primaryTeal, 'Đã làm ($answeredCount)'),
                    _buildLegendItem(AppColors.borderLight, 'Chưa làm ($unAnsweredCount)', isBorder: true),
                    _buildLegendItem(AppColors.accentAmber, 'Cờ ($flaggedCount)'),
                  ],
                ),
              ],
            ),
          ),

          // Question Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPartSection(context, state, 'Part 5: Incomplete Sentences', 101, 130),
                const SizedBox(height: 20),
                _buildPartSection(context, state, 'Part 6: Text Completion', 131, 146),
                const SizedBox(height: 20),
                _buildPartSection(context, state, 'Part 7: Reading Comprehension', 147, 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            shape: BoxShape.circle,
            border: isBorder ? Border.all(color: AppColors.textMuted, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildPartSection(BuildContext context, AppState state, String title, int start, int end) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(end - start + 1, (index) {
            int qNum = start + index;
            bool isAnswered = state.selectedAnswers.containsKey(qNum);
            bool isCurrent = state.currentQuestionNumber == qNum;
            bool isFlagged = state.flaggedQuestions.contains(qNum);

            Color bgColor = Colors.white;
            Color textColor = AppColors.textBody;
            Border? border = Border.all(color: AppColors.borderLight, width: 1.2);

            if (isAnswered) {
              bgColor = AppColors.primaryTeal;
              textColor = Colors.white;
              border = null;
            }

            if (isCurrent) {
              border = Border.all(color: AppColors.primaryNavy, width: 2.2);
            }

            return InkWell(
              onTap: () {
                state.setCurrentQuestionNumber(qNum);
                if (onClose != null) onClose!();
              },
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: border,
                      boxShadow: isCurrent ? [
                        BoxShadow(
                          color: AppColors.primaryNavy.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Text(
                      '$qNum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isFlagged)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
