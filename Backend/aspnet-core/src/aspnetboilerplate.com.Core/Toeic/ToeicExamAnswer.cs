using Abp.Domain.Entities.Auditing;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicExamAnswers")]
public class ToeicExamAnswer : FullAuditedEntity<long>
{
    public long SessionId { get; set; }

    [ForeignKey(nameof(SessionId))]
    public virtual ToeicExamSession Session { get; set; }

    public int QuestionId { get; set; }

    [ForeignKey(nameof(QuestionId))]
    public virtual ToeicQuestion Question { get; set; }

    public int QuestionNumber { get; set; }

    [MaxLength(10)]
    public string SelectedOption { get; set; } // "A", "B", "C", "D" or null

    [MaxLength(10)]
    public string CorrectOption { get; set; }

    public bool IsCorrect { get; set; }
}
