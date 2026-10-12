using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicQuestionDto
{
    public int Id { get; set; }
    public int PartId { get; set; }
    public int? PassageGroupId { get; set; }
    public int QuestionNumber { get; set; }
    public string QuestionText { get; set; }
    public string CorrectOption { get; set; }
    public string Explanation { get; set; }
    public int OrderIndex { get; set; }
    public List<ToeicQuestionOptionDto> Options { get; set; } = new List<ToeicQuestionOptionDto>();
}
