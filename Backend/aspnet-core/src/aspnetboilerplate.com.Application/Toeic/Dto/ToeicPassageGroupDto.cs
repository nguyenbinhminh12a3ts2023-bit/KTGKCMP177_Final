using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicPassageGroupDto
{
    public int Id { get; set; }
    public int PartId { get; set; }
    public string Title { get; set; }
    public string PassageText { get; set; }
    public string PassageImageUrl { get; set; }
    public int OrderIndex { get; set; }
    public List<ToeicQuestionDto> Questions { get; set; } = new List<ToeicQuestionDto>();
}
