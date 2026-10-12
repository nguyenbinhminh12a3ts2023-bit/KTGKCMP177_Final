import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/exam_dialogs.dart';
import '../../widgets/question_grid_drawer.dart';

class StudentExamTakingScreen extends StatefulWidget {
  const StudentExamTakingScreen({super.key});

  @override
  State<StudentExamTakingScreen> createState() => _StudentExamTakingScreenState();
}

class _StudentExamTakingScreenState extends State<StudentExamTakingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _warnDialogShown = false;

  void _checkDialogTriggers(AppState state) {
    // 5 minutes warning dialog
    if (state.shouldShowFiveMinutesDialog && !_warnDialogShown) {
      _warnDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WarningFiveMinutesDialog(
            onDismiss: () {
              Navigator.pop(ctx);
              state.dismissFiveMinutesDialog();
            },
          ),
        );
      });
    }

    // Time Up auto submit dialog
    if (state.isTimeUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const TimeUpDialog(),
        );
      });
    }
  }

  void _showSubmitConfirmDialog(AppState state) {
    int total = 100;
    int answered = state.selectedAnswers.length;
    int unanswered = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => ConfirmSubmitDialog(
        answeredCount: answered,
        unansweredCount: unanswered,
        onConfirm: () async {
          Navigator.pop(ctx);
          await state.submitExam();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final exam = state.currentTakingExam;

    _checkDialogTriggers(state);

    if (exam == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Phòng thi TOEIC Reading'),
        body: Center(
          child: ElevatedButton(
            onPressed: () => state.navigateTo(ActiveScreen.studentExamList),
            child: const Text('Quay lại danh sách đề thi'),
          ),
        ),
      );
    }

    final allQuestions = exam.getAllQuestions();
    final currentQ = allQuestions.firstWhere(
      (q) => q.questionNumber == state.currentQuestionNumber,
      orElse: () => allQuestions.isNotEmpty ? allQuestions.first : ToeicQuestion(questionNumber: 101, questionText: '', options: []),
    );

    // Find current part and passage if applicable
    final currentPart = exam.parts.firstWhere(
      (p) => p.partNumber == state.currentPartFilter,
      orElse: () => exam.parts.first,
    );

    ToeicPassageGroup? currentPassage;
    if (state.currentPartFilter != 5) {
      for (var g in currentPart.passageGroups) {
        if (g.questions.any((q) => q.questionNumber == currentQ.questionNumber)) {
          currentPassage = g;
          break;
        }
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgLight,
      endDrawer: Drawer(
        child: QuestionGridDrawer(
          onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        ),
      ),
      appBar: AppHeader(
        title: '${exam.title} · Thí sinh: ${state.candidateName}',
        subtitle: 'MSSV: ${state.candidateCode} · Part ${state.currentPartFilter}',
        showTimer: true,
      ),
      body: Column(
        children: [
          // Subheader Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: AppColors.surfaceWhite,
            child: Row(
              children: [
                // Part Filter Pills
                _buildPartTab(state, 5, 'Part 5 (101–130)'),
                const SizedBox(width: 8),
                _buildPartTab(state, 6, 'Part 6 (131–146)'),
                const SizedBox(width: 8),
                _buildPartTab(state, 7, 'Part 7 (147–200)'),

                const Spacer(),

                // Progress badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'Đã làm: ${state.selectedAnswers.length}/100 câu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Question Drawer Button
                OutlinedButton.icon(
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  icon: const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textBody),
                  label: const Text('Bảng câu hỏi', style: TextStyle(color: AppColors.textBody, fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: state.isSubmittingExam ? null : () => _showSubmitConfirmDialog(state),
                  icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  label: const Text('Nộp bài thi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Main Taking Interface
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: state.currentPartFilter == 5
                  ? _buildPart5Layout(state, currentQ)
                  : _buildPassageLayout(state, currentPart, currentPassage, currentQ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartTab(AppState state, int partNum, String title) {
    bool isSel = state.currentPartFilter == partNum;
    return InkWell(
      onTap: () => state.setCurrentPartFilter(partNum),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            color: isSel ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPart5Layout(AppState state, ToeicQuestion currentQ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 860),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuestionHeader(state, currentQ),
            const SizedBox(height: 24),
            _buildQuestionPrompt(currentQ),
            const SizedBox(height: 28),
            _buildOptionChoices(state, currentQ),
            const Spacer(),
            _buildBottomNavControls(state),
          ],
        ),
      ),
    );
  }

  Widget _buildPassageLayout(
    AppState state,
    ToeicPart part,
    ToeicPassageGroup? passage,
    ToeicQuestion currentQ,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Passage Text
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        passage?.title.isNotEmpty == true ? passage!.title : 'Bài đọc hiểu',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        passage?.passageText ?? 'Đang tải nội dung bài đọc...',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.65,
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Right Column: Questions & Options
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuestionHeader(state, currentQ),
                const SizedBox(height: 20),
                _buildQuestionPrompt(currentQ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildOptionChoices(state, currentQ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomNavControls(state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(AppState state, ToeicQuestion q) {
    bool isFlagged = state.flaggedQuestions.contains(q.questionNumber);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'CÂU ${q.questionNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Part ${state.currentPartFilter}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),

        // Flag button
        IconButton(
          onPressed: () => state.toggleFlagQuestion(q.questionNumber),
          tooltip: isFlagged ? 'Bỏ đánh dấu cờ' : 'Đánh dấu cờ câu này',
          icon: Icon(
            isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded,
            color: isFlagged ? AppColors.accentAmber : AppColors.textMuted,
            size: 22,
          ),
        ),

        // Clear Answer button
        if (state.selectedAnswers.containsKey(q.questionNumber)) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => state.clearAnswer(q.questionNumber),
            child: const Text('Hủy chọn', style: TextStyle(fontSize: 12, color: AppColors.accentRed)),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionPrompt(ToeicQuestion q) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        q.questionText.isNotEmpty ? q.questionText : '(Chọn phương án chính xác nhất để điền vào chỗ trống)',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildOptionChoices(AppState state, ToeicQuestion q) {
    String? selectedOption = state.selectedAnswers[q.questionNumber];

    return Column(
      children: q.options.map((opt) {
        bool isSelected = selectedOption?.toUpperCase() == opt.optionKey.toUpperCase();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => state.selectAnswer(q.questionNumber, opt.optionKey),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGreenBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryTeal : AppColors.borderLight,
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryTeal : AppColors.bgLight,
                      shape: BoxShape.circle,
                      border: isSelected ? null : Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      opt.optionKey,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textBody,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      opt.optionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryTeal : AppColors.textBody,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavControls(AppState state) {
    bool hasPrevious = state.currentQuestionNumber > 101;
    bool hasNext = state.currentQuestionNumber < 200;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: hasPrevious ? () => state.previousQuestion() : null,
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
          label: const Text('Câu trước'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: AppColors.borderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Text(
          '${state.currentQuestionNumber} / 200',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
        ElevatedButton.icon(
          onPressed: hasNext ? () => state.nextQuestion() : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          label: const Text('Câu tiếp theo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
