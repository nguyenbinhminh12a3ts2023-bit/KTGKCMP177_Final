using Abp.Domain.Entities.Auditing;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicQuestionOptions")]
public class ToeicQuestionOption : FullAuditedEntity<int>
{
    public int QuestionId { get; set; }

    [ForeignKey(nameof(QuestionId))]
    public virtual ToeicQuestion Question { get; set; }

    [Required]
    [MaxLength(10)]
    public string OptionKey { get; set; } // "A", "B", "C", "D"

    public string OptionText { get; set; }

    public bool IsCorrect { get; set; }

    public int OrderIndex { get; set; }
}
