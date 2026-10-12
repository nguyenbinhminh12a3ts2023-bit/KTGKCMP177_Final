using Abp.Domain.Entities.Auditing;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetboilerplate.com.Toeic;

[Table("ToeicPassageGroups")]
public class ToeicPassageGroup : FullAuditedEntity<int>
{
    public int PartId { get; set; }

    [ForeignKey(nameof(PartId))]
    public virtual ToeicPart Part { get; set; }

    [MaxLength(300)]
    public string Title { get; set; }

    public string PassageText { get; set; }

    [MaxLength(1000)]
    public string PassageImageUrl { get; set; }

    public int OrderIndex { get; set; }

    public virtual ICollection<ToeicQuestion> Questions { get; set; } = new List<ToeicQuestion>();
}
