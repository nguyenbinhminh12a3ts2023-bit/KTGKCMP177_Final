namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicQuestionOptionDto
{
    public int Id { get; set; }
    public int QuestionId { get; set; }
    public string OptionKey { get; set; } // "A", "B", "C", "D"
    public string OptionText { get; set; }
    public bool IsCorrect { get; set; }
    public int OrderIndex { get; set; }
}
