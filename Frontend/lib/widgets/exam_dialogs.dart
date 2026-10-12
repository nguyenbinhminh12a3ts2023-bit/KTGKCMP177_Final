import 'package:flutter/material.dart';
import '../constants/theme_colors.dart';

class ConfirmSubmitDialog extends StatelessWidget {
  final int answeredCount;
  final int unansweredCount;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmSubmitDialog({
    super.key,
    required this.answeredCount,
    required this.unansweredCount,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentAmberBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                color: AppColors.accentAmber,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Xác nhận nộp bài thi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn có chắc chắn muốn nộp bài thi TOEIC Reading? Sau khi nộp, bạn sẽ không thể thay đổi các câu trả lời.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$answeredCount',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Đã hoàn thành',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Container(height: 36, width: 1, color: AppColors.borderLight),
                  Column(
                    children: [
                      Text(
                        '$unansweredCount',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: unansweredCount > 0 ? AppColors.accentRed : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Chưa trả lời',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (unansweredCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.accentAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Bạn vẫn còn $unansweredCount câu chưa chọn đáp án.',
                    style: const TextStyle(fontSize: 12, color: AppColors.accentAmber, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 26),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Tiếp tục làm bài',
                      style: TextStyle(color: AppColors.textBody, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Nộp bài thi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WarningFiveMinutesDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const WarningFiveMinutesDialog({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.accentRedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alarm_rounded,
                color: AppColors.accentRed,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cảnh báo: Còn 5 phút!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thời gian làm bài của bạn chỉ còn lại 5 phút. Vui lòng rà soát lại toàn bộ 100 câu hỏi và hoàn thành các câu còn thiếu trước khi hệ thống tự động khóa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Đã hiểu, tiếp tục làm bài',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeUpDialog extends StatelessWidget {
  const TimeUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.accentRedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  color: AppColors.accentRed,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hết giờ làm bài!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Thời gian thi 75 phút đã kết thúc. Toàn bộ quyền chọn đáp án đã bị khóa. Hệ thống đang tự động thu bài và tính điểm cho bạn...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.primaryTeal),
              const SizedBox(height: 12),
              const Text(
                'Đang chấm điểm tự động...',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
