import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class AdminPreviewExamScreen extends StatefulWidget {
  const AdminPreviewExamScreen({super.key});

  @override
  State<AdminPreviewExamScreen> createState() => _AdminPreviewExamScreenState();
}

class _AdminPreviewExamScreenState extends State<AdminPreviewExamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final exam = state.selectedExam;

    if (exam == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Xem trước đề thi'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chưa chọn đề thi để xem trước.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => state.navigateTo(ActiveScreen.adminExamList),
                child: const Text('Quay lại danh sách'),
              ),
            ],
          ),
        ),
      );
    }

    final part5 = exam.parts.firstWhere((p) => p.partNumber == 5, orElse: () => ToeicPart(partNumber: 5, partTitle: 'Part 5', description: '', passageGroups: [], questions: []));
    final part6 = exam.parts.firstWhere((p) => p.partNumber == 6, orElse: () => ToeicPart(partNumber: 6, partTitle: 'Part 6', description: '', passageGroups: [], questions: []));
    final part7 = exam.parts.firstWhere((p) => p.partNumber == 7, orElse: () => ToeicPart(partNumber: 7, partTitle: 'Part 7', description: '', passageGroups: [], questions: []));

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppHeader(
        title: exam.title,
        subtitle: 'Xem trước nội dung đề thi (Chế độ Giảng viên)',
      ),
      body: Column(
        children: [
          // Subheader Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            color: AppColors.surfaceWhite,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => state.navigateTo(ActiveScreen.adminExamList),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Quay lại'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
                const SizedBox(width: 16),

                // Tab Bar
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primaryTeal,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primaryTeal,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Part 5: Câu 101–130 (${part5.getAllQuestions().length} câu)'),
                      Tab(text: 'Part 6: Câu 131–146 (${part6.getAllQuestions().length} câu)'),
                      Tab(text: 'Part 7: Câu 147–200 (${part7.getAllQuestions().length} câu)'),
                    ],
                  ),
                ),

                // Button Chỉnh sửa
                ElevatedButton.icon(
                  onPressed: () => state.selectExamForEdit(exam.id),
                  icon: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                  label: const Text('Chỉnh sửa đề thi này', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPart5View(part5),
                _buildPartWithPassagesView(part6, 'Part 6: Text Completion'),
                _buildPartWithPassagesView(part7, 'Part 7: Reading Comprehension'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPart5View(ToeicPart part) {
    final questions = part.getAllQuestions();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return _buildQuestionCard(q);
      },
    );
  }

  Widget _buildPartWithPassagesView(ToeicPart part, String partLabel) {
    if (part.passageGroups.isEmpty && part.questions.isEmpty) {
      return const Center(child: Text('Không có nội dung cho phần này.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      itemCount: part.passageGroups.length,
      itemBuilder: (context, index) {
        final group = part.passageGroups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Passage Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      group.title.isNotEmpty ? group.title : 'Nhóm câu hỏi bài đọc',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Passage Text
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: SelectableText(
                  group.passageText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textBody,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Questions in group
              ...group.questions.map((q) => _buildQuestionCard(q)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(ToeicQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number & Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Câu ${q.questionNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  q.questionText.isNotEmpty ? q.questionText : '(Chọn từ thích hợp điền vào chỗ trống)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Options Grid
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: q.options.map((opt) {
              bool isCorrect = q.correctOption?.toUpperCase() == opt.optionKey.toUpperCase();

              return Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCorrect ? AppColors.accentGreenBg : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? AppColors.accentGreen : AppColors.borderLight,
                    width: isCorrect ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.primaryTeal : Colors.white,
                        shape: BoxShape.circle,
                        border: isCorrect ? null : Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        opt.optionKey,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCorrect ? Colors.white : AppColors.textBody,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt.optionText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                          color: isCorrect ? AppColors.primaryTeal : AppColors.textBody,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primaryTeal),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
