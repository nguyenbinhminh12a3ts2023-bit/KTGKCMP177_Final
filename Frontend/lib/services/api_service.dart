import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/toeic_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/toeic';

  static Map<String, dynamic> _extractResult(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('result')) {
          return decoded['result'] is Map<String, dynamic>
              ? decoded['result']
              : {'value': decoded['result']};
        }
        return decoded;
      }
      return {'value': decoded};
    } else {
      String errorMessage = 'Lỗi máy chủ (${response.statusCode})';
      try {
        final errJson = json.decode(utf8.decode(response.bodyBytes));
        if (errJson is Map && errJson.containsKey('error') && errJson['error'] != null) {
          errorMessage = errJson['error']['message'] ?? errJson['error']['details'] ?? errorMessage;
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  static Future<List<ToeicExam>> getAllExams() async {
    final response = await http.get(Uri.parse('$baseUrl/exams'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final List list = decoded is Map && decoded.containsKey('result') ? decoded['result'] : decoded;
      return list.map((e) => ToeicExam.fromJson(e)).toList();
    }
    throw Exception('Không thể tải danh sách đề thi (${response.statusCode})');
  }

  static Future<ToeicExam> getExamDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/exams/$id/detail'));
    final result = _extractResult(response);
    return ToeicExam.fromJson(result);
  }

  static Future<ToeicExam> getExamForStudent(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/exams/$id/student'));
    final result = _extractResult(response);
    return ToeicExam.fromJson(result);
  }

  static Future<ToeicExam> seedSampleExam() async {
    final response = await http.get(Uri.parse('$baseUrl/seed'));
    final result = _extractResult(response);
    return ToeicExam.fromJson(result);
  }

  static Future<ToeicValidationResult> uploadAndValidateDocx(Uint8List fileBytes, String fileName) async {
    var uri = Uri.parse('$baseUrl/upload-validate');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final data = decoded is Map && decoded.containsKey('result') ? decoded['result'] : decoded;
      return ToeicValidationResult.fromJson(data);
    } else {
      String msg = 'Kiểm tra thất bại (${response.statusCode})';
      try {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded['error'] != null) {
          msg = decoded['error']['message'] ?? msg;
        }
      } catch (_) {}
      return ToeicValidationResult(
        isValid: false,
        errors: [msg],
        warnings: [],
        examTitle: fileName,
        durationMinutes: 75,
        totalQuestions: 0,
        part5Count: 0,
        part6Count: 0,
        part7Count: 0,
      );
    }
  }

  static Future<ToeicExam> importDocx(Uint8List fileBytes, String fileName) async {
    var uri = Uri.parse('$baseUrl/import');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final result = _extractResult(response);
    return ToeicExam.fromJson(result);
  }

  static Future<ToeicExam> updateExam(ToeicExam exam) async {
    final response = await http.put(
      Uri.parse('$baseUrl/exams/${exam.id}'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode(exam.toJson()),
    );
    final result = _extractResult(response);
    return ToeicExam.fromJson(result);
  }

  static Future<void> deleteExam(int examId) async {
    final response = await http.delete(Uri.parse('$baseUrl/exams/$examId'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Không thể xóa đề thi (${response.statusCode})');
    }
  }

  static Future<ToeicSessionResult> startSession({
    required int examId,
    required String candidateName,
    required String candidateCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions/start'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'examId': examId,
        'candidateName': candidateName,
        'candidateCode': candidateCode,
      }),
    );
    final result = _extractResult(response);
    return ToeicSessionResult.fromJson(result);
  }

  static Future<ToeicSessionResult> submitSession({
    required int sessionId,
    required int timeSpentSeconds,
    required Map<int, String> answers,
  }) async {
    final answersList = answers.entries.map((e) => {
      'questionId': 0,
      'questionNumber': e.key,
      'selectedOption': e.value,
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/submit'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'sessionId': sessionId,
        'timeSpentSeconds': timeSpentSeconds,
        'answers': answersList,
      }),
    );
    final result = _extractResult(response);
    return ToeicSessionResult.fromJson(result);
  }

  static Future<ToeicSessionResult> getSessionResult(int sessionId) async {
    final response = await http.get(Uri.parse('$baseUrl/sessions/$sessionId/result'));
    final result = _extractResult(response);
    return ToeicSessionResult.fromJson(result);
  }
}
