using Abp.Domain.Entities.Auditing;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicParts")]
public class ToeicPart : FullAuditedEntity<int>
{
    public int ExamId { get; set; }

    [ForeignKey(nameof(ExamId))]
    public virtual ToeicExam Exam { get; set; }

    public int PartNumber { get; set; } // 5, 6, 7

    [Required]
    [MaxLength(200)]
    public string PartTitle { get; set; }

    [MaxLength(2000)]
    public string Description { get; set; }

    public int OrderIndex { get; set; }

    public virtual ICollection<ToeicPassageGroup> PassageGroups { get; set; } = new List<ToeicPassageGroup>();
    public virtual ICollection<ToeicQuestion> Questions { get; set; } = new List<ToeicQuestion>();
}
