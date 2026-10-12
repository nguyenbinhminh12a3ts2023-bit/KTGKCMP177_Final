import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class StudentResultScreen extends StatelessWidget {
  const StudentResultScreen({super.key});

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m}p ${s.toString().padLeft(2, '0')}s';
  }

  String _getToeicLevel(int score) {
    if (score >= 450) return 'Xuất sắc (Level C1+)';
    if (score >= 385) return 'Cao cấp (Level B2)';
    if (score >= 275) return 'Trung cấp (Level B1)';
    if (score >= 160) return 'Sơ cấp (Level A2)';
    return 'Cơ bản (Level A1)';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.sessionResult;

    if (result == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Kết quả bài thi'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chưa có kết quả bài thi.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => state.navigateTo(ActiveScreen.studentExamList),
                child: const Text('Về danh sách đề thi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppHeader(
        title: 'Kết quả bài thi: ${result.examTitle}',
        subtitle: 'Thí sinh: ${result.candidateName} (${result.candidateCode})',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Big Score Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left Score Badge
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryTeal, Color(0xFF045B5D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ĐIỂM TOEIC',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          '/ 495 Reading',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Middle Breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Đánh giá trình độ: ${_getToeicLevel(result.score)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Thời gian làm bài: ${_formatTime(result.timeSpentSeconds)} · Tỉ lệ chính xác: ${result.accuracyPercent}%',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),

                        // Stats Grid
                        Row(
                          children: [
                            _buildStatItem('Số câu đúng', '${result.correctAnswersCount}', AppColors.accentGreen, Icons.check_circle_outline),
                            const SizedBox(width: 20),
                            _buildStatItem('Số câu sai', '${result.wrongAnswersCount}', AppColors.accentRed, Icons.highlight_off),
                            const SizedBox(width: 20),
                            _buildStatItem('Chưa làm', '${result.unansweredCount}', AppColors.textMuted, Icons.help_outline),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Actions
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await state.startTakingExam();
                        },
                        icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.white),
                        label: const Text('Thi lại đề này', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => state.navigateTo(ActiveScreen.studentExamList),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('Về trang chủ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Detailed Review Section
            const Text(
              'Bảng đối chiếu đáp án chi tiết (100 câu hỏi):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 14),

            // Questions Table / List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.reviewList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final item = result.reviewList[index];
                  return _buildReviewRow(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(AnswerReviewItem item) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (item.selectedOption == null) {
      statusColor = AppColors.textMuted;
      statusText = 'Bỏ qua';
      statusIcon = Icons.remove_circle_outline;
    } else if (item.isCorrect) {
      statusColor = AppColors.accentGreen;
      statusText = 'Chính xác';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = AppColors.accentRed;
      statusText = 'Chưa đúng';
      statusIcon = Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Question Badge
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              'Câu ${item.questionNumber}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 18),

          // Question Prompt
          Expanded(
            flex: 4,
            child: Text(
              item.questionText?.isNotEmpty == true ? item.questionText! : 'Part ${item.partNumber}',
              style: const TextStyle(fontSize: 13, color: AppColors.textBody),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // Selected Answer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.selectedOption == null ? AppColors.bgLight : (item.isCorrect ? AppColors.accentGreenBg : AppColors.accentRedBg),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Bạn chọn: ${item.selectedOption ?? "--"}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: item.selectedOption == null ? AppColors.textMuted : (item.isCorrect ? AppColors.accentGreen : AppColors.accentRed),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Correct Answer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreenBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Đáp án: ${item.correctOption ?? "A"}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
            ),
          ),

          const SizedBox(width: 16),

          // Status Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
