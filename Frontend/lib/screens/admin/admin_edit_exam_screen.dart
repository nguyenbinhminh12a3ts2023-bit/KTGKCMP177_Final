import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class AdminEditExamScreen extends StatefulWidget {
  const AdminEditExamScreen({super.key});

  @override
  State<AdminEditExamScreen> createState() => _AdminEditExamScreenState();
}

class _AdminEditExamScreenState extends State<AdminEditExamScreen> {
  late TextEditingController _titleController;
  late TextEditingController _durationController;

  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  int _selectedPartNumber = 6;
  int? _selectedPassageIndex = 0;
  int _selectedQuestionNumber = 131;

  ToeicExam? _workingExam;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    if (state.selectedExam != null) {
      _workingExam = ToeicExam.fromJson(state.selectedExam!.toJson());
      _titleController = TextEditingController(text: _workingExam!.title);
      _durationController = TextEditingController(text: _workingExam!.durationMinutes.toString());
    } else {
      _titleController = TextEditingController();
      _durationController = TextEditingController(text: '75');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveChanges(AppState state) async {
    if (_workingExam == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      _workingExam!.title = _titleController.text.trim();
      _workingExam!.durationMinutes = int.tryParse(_durationController.text.trim()) ?? 75;

      await state.saveEditedExam(_workingExam!);

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi vào CSDL MSSQL thành công!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (_workingExam == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Chỉnh sửa đề thi'),
        body: Center(
          child: ElevatedButton(
            onPressed: () => state.navigateTo(ActiveScreen.adminExamList),
            child: const Text('Quay lại danh sách đề thi'),
          ),
        ),
      );
    }

    final currentPart = _workingExam!.parts.firstWhere(
      (p) => p.partNumber == _selectedPartNumber,
      orElse: () => _workingExam!.parts.first,
    );

    ToeicPassageGroup? currentPassage;
    if (currentPart.passageGroups.isNotEmpty) {
      int idx = (_selectedPassageIndex ?? 0).clamp(0, currentPart.passageGroups.length - 1);
      currentPassage = currentPart.passageGroups[idx];
    }

    final allQuestionsInPart = currentPart.getAllQuestions();
    final currentQuestion = allQuestionsInPart.firstWhere(
      (q) => q.questionNumber == _selectedQuestionNumber,
      orElse: () => allQuestionsInPart.isNotEmpty ? allQuestionsInPart.first : ToeicQuestion(questionNumber: 101, questionText: '', options: []),
    );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppHeader(
        title: 'Chỉnh sửa đề thi',
        subtitle: '${_workingExam!.title} · Part $_selectedPartNumber',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status bar & Top Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  // Back button
                  OutlinedButton.icon(
                    onPressed: () => state.navigateTo(ActiveScreen.adminExamList),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Quay lại'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.borderLight)),
                  ),
                  const SizedBox(width: 20),

                  // Title field
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tên đề thi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _titleController,
                          onChanged: (_) => _markChanged(),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Duration field
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thời gian (phút)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _markChanged(),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Save Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _hasUnsavedChanges ? AppColors.accentAmberBg : AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hasUnsavedChanges ? Icons.edit_note : Icons.check_circle_outline,
                          size: 16,
                          color: _hasUnsavedChanges ? AppColors.accentAmber : AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasUnsavedChanges ? 'Có thay đổi chưa lưu' : 'Đã đồng bộ CSDL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _hasUnsavedChanges ? AppColors.accentAmber : AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _saveChanges(state),
                    icon: _isSaving
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save_rounded, size: 16),
                    label: Text(_isSaving ? 'Đang lưu...' : 'Lưu tất cả'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Editor Space (3 Columns matching Figma)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Col 1: Tree Navigation (Part 5, 6, 7 & Passages)
                Container(
                  width: 260,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cấu trúc đề thi',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 12),

                      // Part buttons
                      _buildPartNavButton(5, 'Part 5 (101–130)'),
                      const SizedBox(height: 6),
                      _buildPartNavButton(6, 'Part 6 (131–146)'),
                      const SizedBox(height: 6),
                      _buildPartNavButton(7, 'Part 7 (147–200)'),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 8),

                      if (_selectedPartNumber != 5) ...[
                        Text(
                          'Nhóm đoạn văn (Part $_selectedPartNumber)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(currentPart.passageGroups.length, (idx) {
                          final group = currentPart.passageGroups[idx];
                          bool isSel = _selectedPassageIndex == idx;
                          int startQ = group.questions.isNotEmpty ? group.questions.first.questionNumber : 0;
                          int endQ = group.questions.isNotEmpty ? group.questions.last.questionNumber : 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPassageIndex = idx;
                                  if (group.questions.isNotEmpty) {
                                    _selectedQuestionNumber = group.questions.first.questionNumber;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.accentGreenBg : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? AppColors.primaryTeal : AppColors.borderLight,
                                  ),
                                ),
                                child: Text(
                                  'Nhóm câu $startQ–$endQ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? AppColors.primaryTeal : AppColors.textBody,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 18),

                // Col 2: Passage Editor (Part 6 & Part 7)
                if (_selectedPartNumber != 5 && currentPassage != null) ...[
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Biên tập đoạn đọc',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              Text(
                                '${currentPassage.questions.length} câu phụ thuộc',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Passage Title Field
                          TextFormField(
                            initialValue: currentPassage.title,
                            onChanged: (val) {
                              currentPassage!.title = val;
                              _markChanged();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề đoạn văn',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Passage Content Textarea
                          TextFormField(
                            initialValue: currentPassage.passageText,
                            maxLines: 14,
                            onChanged: (val) {
                              currentPassage!.passageText = val;
                              _markChanged();
                            },
                            style: const TextStyle(fontSize: 13, height: 1.5),
                            decoration: const InputDecoration(
                              labelText: 'Nội dung bài đọc (Văn bản / Chỗ trống [131]...)',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                ],

                // Col 3: Question Editor (4 Options & Correct Answer)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Selector Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: allQuestionsInPart.map((q) {
                            bool isCur = q.questionNumber == _selectedQuestionNumber;
                            return ChoiceChip(
                              label: Text('${q.questionNumber}', style: TextStyle(fontSize: 11, color: isCur ? Colors.white : AppColors.textBody)),
                              selected: isCur,
                              selectedColor: AppColors.primaryNavy,
                              onSelected: (_) {
                                setState(() {
                                  _selectedQuestionNumber = q.questionNumber;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: AppColors.borderLight),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Câu ${currentQuestion.questionNumber}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Question Prompt Input
                        TextFormField(
                          key: ValueKey('q_text_${currentQuestion.questionNumber}'),
                          initialValue: currentQuestion.questionText,
                          maxLines: 2,
                          onChanged: (val) {
                            currentQuestion.questionText = val;
                            _markChanged();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Nội dung câu hỏi',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          'Đáp án lựa chọn & Đáp án đúng:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 10),

                        // Options A, B, C, D
                        ...currentQuestion.options.map((opt) {
                          bool isCorrect = currentQuestion.correctOption?.toUpperCase() == opt.optionKey.toUpperCase();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: opt.optionKey,
                                  groupValue: currentQuestion.correctOption?.toUpperCase(),
                                  activeColor: AppColors.primaryTeal,
                                  onChanged: (val) {
                                    setState(() {
                                      currentQuestion.correctOption = val;
                                      for (var o in currentQuestion.options) {
                                        o.isCorrect = o.optionKey.toUpperCase() == val?.toUpperCase();
                                      }
                                    });
                                    _markChanged();
                                  },
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCorrect ? AppColors.primaryTeal : AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    opt.optionKey,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isCorrect ? Colors.white : AppColors.textBody,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('opt_${currentQuestion.questionNumber}_${opt.optionKey}'),
                                    initialValue: opt.optionText,
                                    onChanged: (val) {
                                      opt.optionText = val;
                                      _markChanged();
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
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

  Widget _buildPartNavButton(int partNum, String title) {
    bool isSel = _selectedPartNumber == partNum;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPartNumber = partNum;
          _selectedPassageIndex = 0;
          if (partNum == 5) _selectedQuestionNumber = 101;
          if (partNum == 6) _selectedQuestionNumber = 131;
          if (partNum == 7) _selectedQuestionNumber = 147;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryNavy : AppColors.bgLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSel ? Colors.white : AppColors.textBody,
          ),
        ),
      ),
    );
  }
}
