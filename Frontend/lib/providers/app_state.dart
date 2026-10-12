import 'dart:async';
import 'package:flutter/material.dart';
import '../models/toeic_models.dart';
import '../services/api_service.dart';

enum UserRole { admin, candidate }

enum ActiveScreen {
  // Admin Screens
  adminExamList,
  adminUploadWord,
  adminPreviewExam,
  adminEditExam,
  
  // Student Screens
  studentExamList,
  studentExamDetail,
  studentExamTaking,
  studentResult,
}

class AppState extends ChangeNotifier {
  UserRole _role = UserRole.admin;
  ActiveScreen _currentScreen = ActiveScreen.adminExamList;

  UserRole get role => _role;
  ActiveScreen get currentScreen => _currentScreen;

  // Admin Data
  List<ToeicExam> _exams = [];
  bool _isLoadingExams = false;
  String? _examListError;

  List<ToeicExam> get exams => _exams;
  bool get isLoadingExams => _isLoadingExams;
  String? get examListError => _examListError;

  ToeicExam? _selectedExam;
  ToeicExam? get selectedExam => _selectedExam;

  ToeicValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isImporting = false;

  ToeicValidationResult? get validationResult => _validationResult;
  bool get isValidating => _isValidating;
  bool get isImporting => _isImporting;

  // Student / Candidate Data
  String _candidateName = "Thí sinh Nguyễn Văn A";
  String _candidateCode = "SV10245";

  String get candidateName => _candidateName;
  String get candidateCode => _candidateCode;

  ToeicExam? _currentTakingExam;
  ToeicExam? get currentTakingExam => _currentTakingExam;

  int? _currentSessionId;
  int? get currentSessionId => _currentSessionId;

  final Map<int, String> _selectedAnswers = {}; // questionNumber -> "A"|"B"|"C"|"D"
  final Set<int> _flaggedQuestions = {};        // questionNumber set
  int _currentQuestionNumber = 101;       // 101..200
  int _currentPartFilter = 5;             // 5, 6, 7

  Map<int, String> get selectedAnswers => _selectedAnswers;
  Set<int> get flaggedQuestions => _flaggedQuestions;
  int get currentQuestionNumber => _currentQuestionNumber;
  int get currentPartFilter => _currentPartFilter;

  // Timer: 75 minutes countdown
  int _remainingSeconds = 75 * 60;
  Timer? _countdownTimer;
  bool _isTimerRunning = false;
  bool _hasWarnedFiveMinutes = false;
  bool _shouldShowFiveMinutesDialog = false;
  bool _isTimeUp = false;
  bool _isSubmittingExam = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isTimerRunning => _isTimerRunning;
  bool get shouldShowFiveMinutesDialog => _shouldShowFiveMinutesDialog;
  bool get isTimeUp => _isTimeUp;
  bool get isSubmittingExam => _isSubmittingExam;

  ToeicSessionResult? _sessionResult;
  ToeicSessionResult? get sessionResult => _sessionResult;

  AppState() {
    loadExams();
  }

  void setRole(UserRole newRole) {
    _role = newRole;
    if (_role == UserRole.admin) {
      _currentScreen = ActiveScreen.adminExamList;
    } else {
      _currentScreen = ActiveScreen.studentExamList;
    }
    notifyListeners();
  }

  void navigateTo(ActiveScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setCandidateInfo(String name, String code) {
    _candidateName = name;
    _candidateCode = code;
    notifyListeners();
  }

  Future<void> loadExams() async {
    _isLoadingExams = true;
    _examListError = null;
    notifyListeners();

    try {
      var list = await ApiService.getAllExams();
      if (list.isEmpty) {
        // Auto-seed if empty
        try {
          var seeded = await ApiService.seedSampleExam();
          list = [seeded];
        } catch (_) {}
      }
      _exams = list;
    } catch (e) {
      _examListError = e.toString();
    } finally {
      _isLoadingExams = false;
      notifyListeners();
    }
  }

  Future<void> selectExamForPreview(int examId) async {
    try {
      _selectedExam = await ApiService.getExamDetail(examId);
      _currentScreen = ActiveScreen.adminPreviewExam;
      notifyListeners();
    } catch (e) {
      _examListError = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectExamForEdit(int examId) async {
    try {
      _selectedExam = await ApiService.getExamDetail(examId);
      _currentScreen = ActiveScreen.adminEditExam;
      notifyListeners();
    } catch (e) {
      _examListError = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveEditedExam(ToeicExam updatedExam) async {
    try {
      var res = await ApiService.updateExam(updatedExam);
      _selectedExam = res;
      await loadExams();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExam(int examId) async {
    try {
      await ApiService.deleteExam(examId);
      await loadExams();
      if (_currentScreen != ActiveScreen.adminExamList) {
        _currentScreen = ActiveScreen.adminExamList;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void setValidationResult(ToeicValidationResult? res) {
    _validationResult = res;
    notifyListeners();
  }

  void setValidating(bool v) {
    _isValidating = v;
    notifyListeners();
  }

  void setImporting(bool v) {
    _isImporting = v;
    notifyListeners();
  }

  // Candidate Exam Session flow
  Future<void> prepareExamForStudent(int examId) async {
    _currentTakingExam = await ApiService.getExamForStudent(examId);
    _currentScreen = ActiveScreen.studentExamDetail;
    notifyListeners();
  }

  Future<void> startTakingExam() async {
    if (_currentTakingExam == null) return;

    _selectedAnswers.clear();
    _flaggedQuestions.clear();
    _currentQuestionNumber = 101;
    _currentPartFilter = 5;
    _remainingSeconds = (_currentTakingExam!.durationMinutes) * 60;
    _hasWarnedFiveMinutes = false;
    _shouldShowFiveMinutesDialog = false;
    _isTimeUp = false;
    _isSubmittingExam = false;

    // Start session in backend
    try {
      var sess = await ApiService.startSession(
        examId: _currentTakingExam!.id,
        candidateName: _candidateName,
        candidateCode: _candidateCode,
      );
      _currentSessionId = sess.sessionId;
    } catch (_) {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch;
    }

    _startCountdownTimer();
    _currentScreen = ActiveScreen.studentExamTaking;
    notifyListeners();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _isTimerRunning = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;

        // Check 5 minutes warning (300 seconds)
        if (_remainingSeconds == 300 && !_hasWarnedFiveMinutes) {
          _hasWarnedFiveMinutes = true;
          _shouldShowFiveMinutesDialog = true;
        }

        notifyListeners();
      } else {
        // Time expired!
        _countdownTimer?.cancel();
        _isTimerRunning = false;
        _isTimeUp = true;
        notifyListeners();
        // Auto submit
        autoSubmitExam();
      }
    });
  }

  void dismissFiveMinutesDialog() {
    _shouldShowFiveMinutesDialog = false;
    notifyListeners();
  }

  void selectAnswer(int questionNumber, String optionKey) {
    if (_isTimeUp || _isSubmittingExam) return; // Locked

    if (_selectedAnswers[questionNumber] == optionKey) {
      // Toggle or keep
    } else {
      _selectedAnswers[questionNumber] = optionKey;
    }
    notifyListeners();
  }

  void clearAnswer(int questionNumber) {
    if (_isTimeUp || _isSubmittingExam) return;
    _selectedAnswers.remove(questionNumber);
    notifyListeners();
  }

  void toggleFlagQuestion(int questionNumber) {
    if (_flaggedQuestions.contains(questionNumber)) {
      _flaggedQuestions.remove(questionNumber);
    } else {
      _flaggedQuestions.add(questionNumber);
    }
    notifyListeners();
  }

  void setCurrentQuestionNumber(int qNum) {
    _currentQuestionNumber = qNum;
    if (qNum <= 130) {
      _currentPartFilter = 5;
    } else if (qNum <= 146) {
      _currentPartFilter = 6;
    } else {
      _currentPartFilter = 7;
    }
    notifyListeners();
  }

  void setCurrentPartFilter(int part) {
    _currentPartFilter = part;
    if (part == 5 && (_currentQuestionNumber < 101 || _currentQuestionNumber > 130)) {
      _currentQuestionNumber = 101;
    } else if (part == 6 && (_currentQuestionNumber < 131 || _currentQuestionNumber > 146)) {
      _currentQuestionNumber = 131;
    } else if (part == 7 && (_currentQuestionNumber < 147 || _currentQuestionNumber > 200)) {
      _currentQuestionNumber = 147;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionNumber < 200) {
      setCurrentQuestionNumber(_currentQuestionNumber + 1);
    }
  }

  void previousQuestion() {
    if (_currentQuestionNumber > 101) {
      setCurrentQuestionNumber(_currentQuestionNumber - 1);
    }
  }

  Future<void> submitExam() async {
    if (_isSubmittingExam) return;
    _isSubmittingExam = true;
    _countdownTimer?.cancel();
    _isTimerRunning = false;
    notifyListeners();

    int totalDuration = (_currentTakingExam?.durationMinutes ?? 75) * 60;
    int timeSpent = totalDuration - _remainingSeconds;

    try {
      if (_currentSessionId != null) {
        var res = await ApiService.submitSession(
          sessionId: _currentSessionId!,
          timeSpentSeconds: timeSpent,
          answers: _selectedAnswers,
        );
        _sessionResult = res;
      }
    } catch (e) {
      // Mock result if connection failure
      _sessionResult = _createLocalResult(timeSpent);
    } finally {
      _isSubmittingExam = false;
      _currentScreen = ActiveScreen.studentResult;
      notifyListeners();
    }
  }

  Future<void> autoSubmitExam() async {
    _isTimeUp = true;
    await submitExam();
  }

  ToeicSessionResult _createLocalResult(int timeSpent) {
    int total = 100;
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;
    List<AnswerReviewItem> reviews = [];

    var allQ = _currentTakingExam?.getAllQuestions() ?? [];
    for (var q in allQ) {
      String? sel = _selectedAnswers[q.questionNumber];
      bool isCor = false;
      if (sel == null) {
        unanswered++;
      } else {
        if (q.correctOption != null && sel.toUpperCase() == q.correctOption!.toUpperCase()) {
          correct++;
          isCor = true;
        } else {
          wrong++;
        }
      }
      reviews.add(AnswerReviewItem(
        questionNumber: q.questionNumber,
        questionText: q.questionText,
        selectedOption: sel,
        correctOption: q.correctOption ?? "A",
        isCorrect: isCor,
        explanation: q.explanation,
        partNumber: q.questionNumber <= 130 ? 5 : (q.questionNumber <= 146 ? 6 : 7),
      ));
    }

    return ToeicSessionResult(
      sessionId: _currentSessionId ?? 1,
      examId: _currentTakingExam?.id ?? 1,
      examTitle: _currentTakingExam?.title ?? "TOEIC Reading Test",
      candidateName: _candidateName,
      candidateCode: _candidateCode,
      timeSpentSeconds: timeSpent,
      totalQuestions: total,
      correctAnswersCount: correct,
      wrongAnswersCount: wrong,
      unansweredCount: unanswered,
      score: correct * 5,
      accuracyPercent: total > 0 ? (correct / total * 100) : 0,
      status: "Submitted",
      reviewList: reviews,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
