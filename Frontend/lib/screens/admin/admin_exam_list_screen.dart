import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';

class AdminExamListScreen extends StatefulWidget {
  const AdminExamListScreen({super.key});

  @override
  State<AdminExamListScreen> createState() => _AdminExamListScreenState();
}

class _AdminExamListScreenState extends State<AdminExamListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final filteredExams = state.exams.where((e) {
      if (_searchQuery.isEmpty) return true;
      return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.sourceFileName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppHeader(
        title: 'Quản lý đề thi TOEIC Reading',
        subtitle: 'Bảng điều khiển Giảng viên / Quản trị viên',
      ),
      body: state.isLoadingExams
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryTeal),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách đề thi từ MSSQL...', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Summary Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.menu_book_rounded,
                          iconColor: AppColors.primaryTeal,
                          iconBg: AppColors.accentGreenBg,
                          title: 'Tổng số đề thi',
                          value: '${state.exams.length}',
                          subText: 'Đã lưu trong CSDL',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.timer_outlined,
                          iconColor: AppColors.primaryNavy,
                          iconBg: const Color(0xFFE2E8F0),
                          title: 'Thời gian thi chuẩn',
                          value: '75 phút',
                          subText: 'Đếm ngược tự động',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.format_list_numbered_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFFEDE9FE),
                          title: 'Số câu hỏi chuẩn',
                          value: '100 câu',
                          subText: 'Part 5, 6, 7 chuẩn ETS',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.storage_rounded,
                          iconColor: AppColors.accentAmber,
                          iconBg: AppColors.accentAmberBg,
                          title: 'Hệ quản trị CSDL',
                          value: 'MSSQL',
                          subText: 'comDb (Localhost)',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Search and Action Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        // Search Box
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm theo tên đề thi, mã đề, file nguồn...',
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.bgLight,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Refresh button
                        IconButton(
                          onPressed: () => state.loadExams(),
                          tooltip: 'Làm mới danh sách',
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
                        ),

                        const SizedBox(width: 8),

                        // Import Word Button
                        ElevatedButton.icon(
                          onPressed: () {
                            state.navigateTo(ActiveScreen.adminUploadWord);
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 18, color: Colors.white),
                          label: const Text('Nhập đề từ Word (.docx)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Exam Table Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: filteredExams.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded, size: 64, color: AppColors.borderLight),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có đề thi nào trong hệ thống',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Bạn có thể nhập đề mới từ file Word (.docx) hoặc nạp file mẫu DeThiGiuaKy_Reading_v07.docx',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => state.navigateTo(ActiveScreen.adminUploadWord),
                                  icon: const Icon(Icons.upload_file, size: 18, color: Colors.white),
                                  label: const Text('Tải file .docx ngay', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryTeal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredExams.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                            itemBuilder: (context, index) {
                              final exam = filteredExams[index];
                              return _buildExamRow(context, state, exam);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subText, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRow(BuildContext context, AppState state, ToeicExam exam) {
    String formattedDate = exam.creationTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(exam.creationTime!)
        : 'Vừa xong';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          // Exam icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_rounded, color: AppColors.primaryTeal, size: 24),
          ),
          const SizedBox(width: 18),

          // Title & metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreenBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Đã xuất bản',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${exam.durationMinutes} phút', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(width: 14),
                    const Icon(Icons.quiz_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${exam.totalQuestions} câu hỏi', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    if (exam.sourceFileName != null) ...[
                      const SizedBox(width: 14),
                      const Icon(Icons.description_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(exam.sourceFileName!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                    const SizedBox(width: 14),
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Xem trước
              OutlinedButton.icon(
                onPressed: () => state.selectExamForPreview(exam.id),
                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textBody),
                label: const Text('Xem trước', style: TextStyle(color: AppColors.textBody, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),

              // Chỉnh sửa
              ElevatedButton.icon(
                onPressed: () => state.selectExamForEdit(exam.id),
                icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                label: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),

              // Thi thử
              ElevatedButton.icon(
                onPressed: () async {
                  await state.prepareExamForStudent(exam.id);
                  state.setRole(UserRole.candidate);
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                label: const Text('Thi thử', style: TextStyle(color: Colors.white, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),

              // Xóa
              IconButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa đề thi'),
                      content: Text('Bạn có chắc chắn muốn xóa "${exam.title}" khỏi hệ thống? Thao tác này không thể hoàn tác.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
                          child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await state.deleteExam(exam.id);
                  }
                },
                tooltip: 'Xóa đề thi',
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.accentRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
