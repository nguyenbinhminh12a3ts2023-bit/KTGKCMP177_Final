using Abp.Domain.Entities.Auditing;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicExamSessions")]
public class ToeicExamSession : FullAuditedEntity<long>
{
    public int ExamId { get; set; }

    [ForeignKey(nameof(ExamId))]
    public virtual ToeicExam Exam { get; set; }

    [Required]
    [MaxLength(100)]
    public string CandidateName { get; set; }

    [MaxLength(50)]
    public string CandidateCode { get; set; }

    public DateTime StartTime { get; set; }

    public DateTime? EndTime { get; set; }

    public int TimeSpentSeconds { get; set; }

    public int TotalQuestions { get; set; } = 100;

    public int CorrectAnswersCount { get; set; }

    public int WrongAnswersCount { get; set; }

    public int UnansweredCount { get; set; }

    public int Score { get; set; } // Scaled TOEIC Reading score (5 - 495)

    public ToeicSessionStatus Status { get; set; } = ToeicSessionStatus.InProgress;

    public virtual ICollection<ToeicExamAnswer> Answers { get; set; } = new List<ToeicExamAnswer>();
}
