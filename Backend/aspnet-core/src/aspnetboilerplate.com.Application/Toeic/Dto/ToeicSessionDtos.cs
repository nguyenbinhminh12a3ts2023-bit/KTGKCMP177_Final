using System;
using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class StartExamSessionDto
{
    public int ExamId { get; set; }
    public string CandidateName { get; set; }
    public string CandidateCode { get; set; }
}

public class SubmitAnswerItemDto
{
    public int QuestionId { get; set; }
    public int QuestionNumber { get; set; }
    public string SelectedOption { get; set; } // "A", "B", "C", "D" or null
}

public class SubmitExamSessionDto
{
    public long SessionId { get; set; }
    public int TimeSpentSeconds { get; set; }
    public List<SubmitAnswerItemDto> Answers { get; set; } = new List<SubmitAnswerItemDto>();
}

public class AnswerReviewItemDto
{
    public int QuestionNumber { get; set; }
    public string QuestionText { get; set; }
    public string SelectedOption { get; set; }
    public string CorrectOption { get; set; }
    public bool IsCorrect { get; set; }
    public string Explanation { get; set; }
    public int PartNumber { get; set; }
}

public class ToeicSessionResultDto
{
    public long SessionId { get; set; }
    public int ExamId { get; set; }
    public string ExamTitle { get; set; }
    public string CandidateName { get; set; }
    public string CandidateCode { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public int TimeSpentSeconds { get; set; }
    public int TotalQuestions { get; set; }
    public int CorrectAnswersCount { get; set; }
    public int WrongAnswersCount { get; set; }
    public int UnansweredCount { get; set; }
    public int Score { get; set; } // 5 - 495
    public double AccuracyPercent { get; set; }
    public string Status { get; set; }
    public List<AnswerReviewItemDto> ReviewList { get; set; } = new List<AnswerReviewItemDto>();
}

public class UpdateExamDto
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public int DurationMinutes { get; set; }
    public List<ToeicPartDto> Parts { get; set; }
}
