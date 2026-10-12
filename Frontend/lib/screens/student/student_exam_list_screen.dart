import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class StudentExamListScreen extends StatelessWidget {
  const StudentExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppHeader(
        title: 'Đề thi · TOEIC Reading',
        subtitle: 'Cổng thi trực tuyến dành cho Thí sinh',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Hero Banner
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryNavy, Color(0xFF0F2338)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'KỲ THI GIỮA KỲ TOEIC READING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kiểm tra năng lực Đọc hiểu TOEIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thời gian làm bài: 75 phút gồm 100 câu hỏi (Part 5, 6, 7). Đồng hồ đếm ngược tự động, hệ thống tự động thu bài và khóa quyền chọn đáp án khi hết giờ.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section Header
            const Row(
              children: [
                Text(
                  'Danh sách đề thi có sẵn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exam Cards Grid
            if (state.isLoadingExams)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
            else if (state.exams.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Hiện tại chưa có đề thi nào được mở.', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 440,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: state.exams.length,
                itemBuilder: (context, index) {
                  final exam = state.exams[index];
                  return _buildExamCard(context, state, exam);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, AppState state, ToeicExam exam) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primaryTeal, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã đề: ${exam.code}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chips
          Row(
            children: [
              _buildBadge(Icons.timer_outlined, '${exam.durationMinutes} phút'),
              const SizedBox(width: 8),
              _buildBadge(Icons.quiz_outlined, '${exam.totalQuestions} câu hỏi'),
              const SizedBox(width: 8),
              _buildBadge(Icons.verified_outlined, 'ETS Reading'),
            ],
          ),

          const Spacer(),

          // Start Test Button
          ElevatedButton.icon(
            onPressed: () async {
              await state.prepareExamForStudent(exam.id);
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Bắt đầu làm bài',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textBody, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
