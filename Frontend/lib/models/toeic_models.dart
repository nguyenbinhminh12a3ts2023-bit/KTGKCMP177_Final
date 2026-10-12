class ToeicOption {
  int id;
  int questionId;
  String optionKey;
  String optionText;
  bool isCorrect;
  int orderIndex;

  ToeicOption({
    this.id = 0,
    this.questionId = 0,
    required this.optionKey,
    required this.optionText,
    this.isCorrect = false,
    this.orderIndex = 0,
  });

  factory ToeicOption.fromJson(Map<String, dynamic> json) {
    return ToeicOption(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      optionKey: json['optionKey'] ?? '',
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionId': questionId,
    'optionKey': optionKey,
    'optionText': optionText,
    'isCorrect': isCorrect,
    'orderIndex': orderIndex,
  };
}

class ToeicQuestion {
  int id;
  int partId;
  int? passageGroupId;
  int questionNumber;
  String questionText;
  String? correctOption;
  String? explanation;
  int orderIndex;
  List<ToeicOption> options;

  ToeicQuestion({
    this.id = 0,
    this.partId = 0,
    this.passageGroupId,
    required this.questionNumber,
    required this.questionText,
    this.correctOption,
    this.explanation,
    this.orderIndex = 0,
    required this.options,
  });

  factory ToeicQuestion.fromJson(Map<String, dynamic> json) {
    var rawOpts = json['options'] as List? ?? [];
    return ToeicQuestion(
      id: json['id'] ?? 0,
      partId: json['partId'] ?? 0,
      passageGroupId: json['passageGroupId'],
      questionNumber: json['questionNumber'] ?? 0,
      questionText: json['questionText'] ?? '',
      correctOption: json['correctOption'],
      explanation: json['explanation'],
      orderIndex: json['orderIndex'] ?? 0,
      options: rawOpts.map((o) => ToeicOption.fromJson(o)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'partId': partId,
    'passageGroupId': passageGroupId,
    'questionNumber': questionNumber,
    'questionText': questionText,
    'correctOption': correctOption,
    'explanation': explanation,
    'orderIndex': orderIndex,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

class ToeicPassageGroup {
  int id;
  int partId;
  String title;
  String passageText;
  String? passageImageUrl;
  int orderIndex;
  List<ToeicQuestion> questions;

  ToeicPassageGroup({
    this.id = 0,
    this.partId = 0,
    required this.title,
    required this.passageText,
    this.passageImageUrl,
    this.orderIndex = 0,
    required this.questions,
  });

  factory ToeicPassageGroup.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    return ToeicPassageGroup(
      id: json['id'] ?? 0,
      partId: json['partId'] ?? 0,
      title: json['title'] ?? '',
      passageText: json['passageText'] ?? '',
      passageImageUrl: json['passageImageUrl'],
      orderIndex: json['orderIndex'] ?? 0,
      questions: rawQuestions.map((q) => ToeicQuestion.fromJson(q)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'partId': partId,
    'title': title,
    'passageText': passageText,
    'passageImageUrl': passageImageUrl,
    'orderIndex': orderIndex,
    'questions': questions.map((q) => q.toJson()).toList(),
  };
}

class ToeicPart {
  int id;
  int examId;
  int partNumber;
  String partTitle;
  String description;
  int orderIndex;
  List<ToeicPassageGroup> passageGroups;
  List<ToeicQuestion> questions;

  ToeicPart({
    this.id = 0,
    this.examId = 0,
    required this.partNumber,
    required this.partTitle,
    required this.description,
    this.orderIndex = 0,
    required this.passageGroups,
    required this.questions,
  });

  factory ToeicPart.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['passageGroups'] as List? ?? [];
    var rawQuestions = json['questions'] as List? ?? [];
    return ToeicPart(
      id: json['id'] ?? 0,
      examId: json['examId'] ?? 0,
      partNumber: json['partNumber'] ?? 0,
      partTitle: json['partTitle'] ?? '',
      description: json['description'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
      passageGroups: rawGroups.map((g) => ToeicPassageGroup.fromJson(g)).toList(),
      questions: rawQuestions.map((q) => ToeicQuestion.fromJson(q)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'examId': examId,
    'partNumber': partNumber,
    'partTitle': partTitle,
    'description': description,
    'orderIndex': orderIndex,
    'passageGroups': passageGroups.map((g) => g.toJson()).toList(),
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  List<ToeicQuestion> getAllQuestions() {
    List<ToeicQuestion> all = [];
    all.addAll(questions);
    for (var g in passageGroups) {
      all.addAll(g.questions);
    }
    all.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return all;
  }
}

class ToeicExam {
  int id;
  String code;
  String title;
  String? description;
  int durationMinutes;
  int totalQuestions;
  int status;
  bool isActive;
  String? sourceFileName;
  DateTime? creationTime;
  List<ToeicPart> parts;

  ToeicExam({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.durationMinutes = 75,
    this.totalQuestions = 100,
    this.status = 1,
    this.isActive = true,
    this.sourceFileName,
    this.creationTime,
    required this.parts,
  });

  factory ToeicExam.fromJson(Map<String, dynamic> json) {
    var rawParts = json['parts'] as List? ?? [];
    return ToeicExam(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 100,
      status: json['status'] ?? 1,
      isActive: json['isActive'] ?? true,
      sourceFileName: json['sourceFileName'],
      creationTime: json['creationTime'] != null ? DateTime.tryParse(json['creationTime']) : null,
      parts: rawParts.map((p) => ToeicPart.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'description': description,
    'durationMinutes': durationMinutes,
    'totalQuestions': totalQuestions,
    'status': status,
    'isActive': isActive,
    'sourceFileName': sourceFileName,
    'parts': parts.map((p) => p.toJson()).toList(),
  };

  List<ToeicQuestion> getAllQuestions() {
    List<ToeicQuestion> all = [];
    for (var p in parts) {
      all.addAll(p.getAllQuestions());
    }
    all.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return all;
  }
}

class ToeicValidationResult {
  bool isValid;
  List<String> errors;
  List<String> warnings;
  String examTitle;
  int durationMinutes;
  int totalQuestions;
  int part5Count;
  int part6Count;
  int part7Count;
  ToeicExam? previewData;

  ToeicValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.examTitle,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.part5Count,
    required this.part6Count,
    required this.part7Count,
    this.previewData,
  });

  factory ToeicValidationResult.fromJson(Map<String, dynamic> json) {
    var errs = (json['errors'] as List? ?? []).map((e) => e.toString()).toList();
    var warns = (json['warnings'] as List? ?? []).map((w) => w.toString()).toList();
    return ToeicValidationResult(
      isValid: json['isValid'] ?? false,
      errors: errs,
      warnings: warns,
      examTitle: json['examTitle'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 0,
      part5Count: json['part5Count'] ?? 0,
      part6Count: json['part6Count'] ?? 0,
      part7Count: json['part7Count'] ?? 0,
      previewData: json['previewData'] != null ? ToeicExam.fromJson(json['previewData']) : null,
    );
  }
}

class AnswerReviewItem {
  int questionNumber;
  String? questionText;
  String? selectedOption;
  String? correctOption;
  bool isCorrect;
  String? explanation;
  int partNumber;

  AnswerReviewItem({
    required this.questionNumber,
    this.questionText,
    this.selectedOption,
    this.correctOption,
    required this.isCorrect,
    this.explanation,
    required this.partNumber,
  });

  factory AnswerReviewItem.fromJson(Map<String, dynamic> json) {
    return AnswerReviewItem(
      questionNumber: json['questionNumber'] ?? 0,
      questionText: json['questionText'],
      selectedOption: json['selectedOption'],
      correctOption: json['correctOption'],
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'],
      partNumber: json['partNumber'] ?? 5,
    );
  }
}

class ToeicSessionResult {
  int sessionId;
  int examId;
  String examTitle;
  String candidateName;
  String candidateCode;
  DateTime? startTime;
  DateTime? endTime;
  int timeSpentSeconds;
  int totalQuestions;
  int correctAnswersCount;
  int wrongAnswersCount;
  int unansweredCount;
  int score;
  double accuracyPercent;
  String status;
  List<AnswerReviewItem> reviewList;

  ToeicSessionResult({
    required this.sessionId,
    required this.examId,
    required this.examTitle,
    required this.candidateName,
    required this.candidateCode,
    this.startTime,
    this.endTime,
    required this.timeSpentSeconds,
    required this.totalQuestions,
    required this.correctAnswersCount,
    required this.wrongAnswersCount,
    required this.unansweredCount,
    required this.score,
    required this.accuracyPercent,
    required this.status,
    required this.reviewList,
  });

  factory ToeicSessionResult.fromJson(Map<String, dynamic> json) {
    var rawReviews = json['reviewList'] as List? ?? [];
    return ToeicSessionResult(
      sessionId: json['sessionId'] ?? 0,
      examId: json['examId'] ?? 0,
      examTitle: json['examTitle'] ?? '',
      candidateName: json['candidateName'] ?? '',
      candidateCode: json['candidateCode'] ?? '',
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 100,
      correctAnswersCount: json['correctAnswersCount'] ?? 0,
      wrongAnswersCount: json['wrongAnswersCount'] ?? 0,
      unansweredCount: json['unansweredCount'] ?? 0,
      score: json['score'] ?? 5,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      reviewList: rawReviews.map((r) => AnswerReviewItem.fromJson(r)).toList(),
    );
  }
}
