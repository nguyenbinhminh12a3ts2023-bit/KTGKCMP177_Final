import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class StudentExamDetailScreen extends StatefulWidget {
  const StudentExamDetailScreen({super.key});

  @override
  State<StudentExamDetailScreen> createState() => _StudentExamDetailScreenState();
}

class _StudentExamDetailScreenState extends State<StudentExamDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nameController = TextEditingController(text: state.candidateName);
    _codeController = TextEditingController(text: state.candidateCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final exam = state.currentTakingExam;

    if (exam == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Chi tiết đề thi'),
        body: Center(
          child: ElevatedButton(
            onPressed: () => state.navigateTo(ActiveScreen.studentExamList),
            child: const Text('Quay lại danh sách đề thi'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppHeader(
        title: exam.title,
        subtitle: 'Thông tin quy chế và chuẩn bị làm bài thi',
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Phần thi Đọc hiểu (Reading Section - 100 Câu hỏi)',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 20),

                // Key Specs Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecBox('Thời gian thi', '${exam.durationMinutes} phút', Icons.timer_outlined, AppColors.primaryTeal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSpecBox('Tổng số câu', '${exam.totalQuestions} câu', Icons.quiz_outlined, AppColors.primaryNavy),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSpecBox('Thang điểm', '5 – 495 điểm', Icons.military_tech_outlined, AppColors.accentAmber),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Candidate Input Section
                const Text(
                  'Thông tin thí sinh dự thi:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên thí sinh',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Mã số sinh viên (MSSV)',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Test Rules & Structure
                const Text(
                  'Cấu trúc bài thi và quy chế:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),

                _buildRuleItem('Part 5 (Câu 101 – 130)', '30 câu hỏi hoàn thành câu độc lập, 4 đáp án A, B, C, D.'),
                _buildRuleItem('Part 6 (Câu 131 – 146)', '16 câu hỏi hoàn thành đoạn văn, chỗ trống nằm trong bài đọc.'),
                _buildRuleItem('Part 7 (Câu 147 – 200)', '54 câu hỏi đọc hiểu đơn và đa đoạn văn.'),
                _buildRuleItem('Đồng hồ đếm ngược', 'Hệ thống tự động tính giờ 75 phút và cảnh báo khi còn 5 phút.'),
                _buildRuleItem('Thu bài tự động', 'Hết 75 phút hệ thống sẽ tự động khóa và thu bài thi.'),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => state.navigateTo(ActiveScreen.studentExamList),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Quay lại', style: TextStyle(color: AppColors.textBody, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          state.setCandidateInfo(_nameController.text, _codeController.text);
                          await state.startTakingExam();
                        },
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                        label: const Text(
                          'Bắt đầu tính giờ & Vào thi',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Expanded(
            child: Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textBody)),
          ),
        ],
      ),
    );
  }
}
