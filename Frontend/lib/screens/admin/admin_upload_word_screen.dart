import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme_colors.dart';
import '../../models/toeic_models.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';

class AdminUploadWordScreen extends StatefulWidget {
  const AdminUploadWordScreen({super.key});

  @override
  State<AdminUploadWordScreen> createState() => _AdminUploadWordScreenState();
}

class _AdminUploadWordScreenState extends State<AdminUploadWordScreen> {
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  int _fileSizeBytes = 0;

  ToeicValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isImporting = false;

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final length = (await file.length()) ?? bytes.length;
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
          _fileSizeBytes = length;
          _validationResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn file: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _validateFile() async {
    if (_selectedFileBytes == null || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn file .docx trước khi kiểm tra.')),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    try {
      final res = await ApiService.uploadAndValidateDocx(_selectedFileBytes!, _selectedFileName!);
      setState(() {
        _validationResult = res;
      });
    } catch (e) {
      setState(() {
        _validationResult = ToeicValidationResult(
          isValid: false,
          errors: ['Lỗi kết nối hoặc xử lý file: $e'],
          warnings: [],
          examTitle: _selectedFileName ?? '',
          durationMinutes: 75,
          totalQuestions: 0,
          part5Count: 0,
          part6Count: 0,
          part7Count: 0,
        );
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  Future<void> _importFile(AppState state) async {
    if (_selectedFileBytes == null || _selectedFileName == null) return;

    setState(() {
      _isImporting = true;
    });

    try {
      await ApiService.importDocx(_selectedFileBytes!, _selectedFileName!);
      await state.loadExams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã import đề thi vào MSSQL thành công 100%!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        state.navigateTo(ActiveScreen.adminExamList);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu đề thi: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppHeader(
        title: 'Nhập đề thi từ file Word (.docx)',
        subtitle: 'Hệ thống kiểm tra cú pháp bộ thẻ định dạng chuẩn',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back Button
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => state.navigateTo(ActiveScreen.adminExamList),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textBody),
                  label: const Text('Quay lại danh sách đề thi', style: TextStyle(color: AppColors.textBody, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Content: Upload Zone & Tag Guidelines
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Upload card & Results
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Upload Box
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: _pickFile,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedFileBytes != null ? AppColors.primaryTeal : AppColors.borderLight,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: _selectedFileBytes != null ? AppColors.accentGreenBg : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _selectedFileBytes != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                                        size: 32,
                                        color: _selectedFileBytes != null ? AppColors.primaryTeal : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _selectedFileName != null
                                          ? _selectedFileName!
                                          : 'Nhấn để chọn file Word đề thi (.docx)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedFileName != null ? AppColors.primaryTeal : AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _selectedFileBytes != null
                                          ? 'Kích thước: ${(_fileSizeBytes / 1024).toStringAsFixed(1)} KB'
                                          : 'Hỗ trợ định dạng file Microsoft Word .docx',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: _pickFile,
                                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                                      label: Text(_selectedFileBytes != null ? 'Chọn file khác' : 'Duyệt tệp từ máy tính'),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.borderLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _selectedFileBytes == null || _isValidating
                                        ? null
                                        : _validateFile,
                                    icon: _isValidating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Icon(Icons.rule_rounded, size: 18),
                                    label: Text(_isValidating ? 'Đang kiểm tra...' : 'Kiểm tra định dạng file (Validate)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                if (_validationResult != null && _validationResult!.isValid) ...[
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isImporting ? null : () => _importFile(state),
                                      icon: _isImporting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Icon(Icons.save_rounded, size: 18),
                                      label: Text(_isImporting ? 'Đang lưu vào MSSQL...' : 'Lưu vào CSDL MSSQL'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryTeal,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Validation Outcome: Success or Error
                      if (_validationResult != null) ...[
                        if (_validationResult!.isValid)
                          _buildSuccessCard()
                        else
                          _buildErrorCard(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right Column: Tags Standard Guideline
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreenBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.code_rounded, size: 18, color: AppColors.primaryTeal),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Quy chuẩn bộ thẻ (Tags)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'File Word (.docx) BẮT BUỘC tuân thủ định dạng bộ thẻ bên dưới để hệ thống phân tích chính xác:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        _buildTagItem('[TEST]', 'Khai báo bắt đầu đề thi'),
                        _buildTagItem('[TITLE: Tên đề thi]', 'Tiêu đề đề thi (VD: TOEIC Reading Test 07)'),
                        _buildTagItem('[TIME: 75]', 'Thời gian thi (phút)'),
                        _buildTagItem('[TOTAL_QUESTIONS: 100]', 'Tổng số câu (100 câu)'),
                        _buildTagItem('[PART: 5|6|7]', 'Phân chia phần thi Part 5, 6, 7'),
                        _buildTagItem('[PASSAGE_TITLE: Tiêu đề]', 'Tiêu đề bài đọc (Part 6, 7)'),
                        _buildTagItem('[PASSAGE] ... [/PASSAGE]', 'Đoạn văn đọc hiểu (Part 6, 7)'),
                        _buildTagItem('[QUESTION: 101]', 'Đánh số câu hỏi liên tục 101–200'),
                        _buildTagItem('[A] [B] [C] [D]', 'Đủ 4 lựa chọn cho mỗi câu'),
                        _buildTagItem('[ANSWER: A]', 'Chỉ định đáp án đúng (A, B, C, D)'),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmberBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentAmber.withOpacity(0.3)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.accentAmber),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nguyên tắc: Nếu sai sót bất kỳ thẻ nào, hệ thống sẽ hủy bỏ toàn bộ và không lưu vào CSDL.',
                                  style: TextStyle(fontSize: 11, color: AppColors.accentAmber, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildTagItem(String tag, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 11, color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiểm tra thành công! File đạt chuẩn 100%',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Không phát hiện lỗi định dạng nào trong file.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Detail metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Tổng số câu', '${_validationResult!.totalQuestions}', AppColors.primaryTeal),
              _buildMetricItem('Part 5', '${_validationResult!.part5Count} câu', AppColors.part5Badge),
              _buildMetricItem('Part 6', '${_validationResult!.part6Count} câu', AppColors.part6Badge),
              _buildMetricItem('Part 7', '${_validationResult!.part7Count} câu', AppColors.part7Badge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentRedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_rounded, color: AppColors.accentRed, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phát hiện lỗi định dạng! Không đủ điều kiện lưu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentRed),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Hệ thống đã hủy bỏ toàn bộ và KHÔNG lưu vào CSDL. Vui lòng sửa file theo các lỗi dưới đây:',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.accentRed),
          const SizedBox(height: 8),

          // List of errors
          ...List.generate(_validationResult!.errors.length, (idx) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      _validationResult!.errors[idx],
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
