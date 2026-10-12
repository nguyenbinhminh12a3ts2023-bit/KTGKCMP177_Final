using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicValidationResultDto
{
    public bool IsValid { get; set; }
    public List<string> Errors { get; set; } = new List<string>();
    public List<string> Warnings { get; set; } = new List<string>();
    public string ExamTitle { get; set; }
    public int DurationMinutes { get; set; }
    public int TotalQuestions { get; set; }
    public int Part5Count { get; set; }
    public int Part6Count { get; set; }
    public int Part7Count { get; set; }
    public ToeicExamDto PreviewData { get; set; }
}
