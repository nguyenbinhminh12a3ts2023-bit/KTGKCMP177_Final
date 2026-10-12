using Abp.Domain.Entities.Auditing;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicExams")]
public class ToeicExam : FullAuditedEntity<int>
{
    [Required]
    [MaxLength(100)]
    public string Code { get; set; }

    [Required]
    [MaxLength(250)]
    public string Title { get; set; }

    [MaxLength(1000)]
    public string Description { get; set; }

    public int DurationMinutes { get; set; } = 75;

    public int TotalQuestions { get; set; } = 100;

    public ToeicExamStatus Status { get; set; } = ToeicExamStatus.Published;

    public bool IsActive { get; set; } = true;

    [MaxLength(500)]
    public string SourceFileName { get; set; }

    public virtual ICollection<ToeicPart> Parts { get; set; } = new List<ToeicPart>();
    public virtual ICollection<ToeicExamSession> Sessions { get; set; } = new List<ToeicExamSession>();
}
