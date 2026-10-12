using Abp.Domain.Entities.Auditing;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicQuestions")]
public class ToeicQuestion : FullAuditedEntity<int>
{
    public int PartId { get; set; }

    [ForeignKey(nameof(PartId))]
    public virtual ToeicPart Part { get; set; }

    public int? PassageGroupId { get; set; }

    [ForeignKey(nameof(PassageGroupId))]
    public virtual ToeicPassageGroup PassageGroup { get; set; }

    public int QuestionNumber { get; set; }

    public string QuestionText { get; set; }

    [MaxLength(10)]
    public string CorrectOption { get; set; } // "A", "B", "C", "D"

    public string Explanation { get; set; }

    public int OrderIndex { get; set; }

    public virtual ICollection<ToeicQuestionOption> Options { get; set; } = new List<ToeicQuestionOption>();
}
