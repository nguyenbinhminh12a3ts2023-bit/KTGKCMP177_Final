using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicPartDto
{
    public int Id { get; set; }
    public int ExamId { get; set; }
    public int PartNumber { get; set; } // 5, 6, 7
    public string PartTitle { get; set; }
    public string Description { get; set; }
    public int OrderIndex { get; set; }
    public List<ToeicPassageGroupDto> PassageGroups { get; set; } = new List<ToeicPassageGroupDto>();
    public List<ToeicQuestionDto> Questions { get; set; } = new List<ToeicQuestionDto>();
}
