using System;
using System.Collections.Generic;

namespace aspnetboilerplate.com.Toeic.Dto;

public class ToeicExamDto
{
    public int Id { get; set; }
    public string Code { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public int DurationMinutes { get; set; } = 75;
    public int TotalQuestions { get; set; } = 100;
    public ToeicExamStatus Status { get; set; }
    public bool IsActive { get; set; } = true;
    public string SourceFileName { get; set; }
    public DateTime CreationTime { get; set; }
    public List<ToeicPartDto> Parts { get; set; } = new List<ToeicPartDto>();
}
