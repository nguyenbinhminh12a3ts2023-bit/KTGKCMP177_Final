using aspnetboilerplate.com.Toeic.Dto;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace aspnetboilerplate.com.Toeic.Services;

public class ToeicWordParser : IToeicWordParser
{
    private static readonly XNamespace W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

    public ToeicValidationResultDto ParseAndValidate(Stream docxStream, string fileName = null)
    {
        var result = new ToeicValidationResultDto();
        var lines = ExtractParagraphs(docxStream, result);

        if (result.Errors.Count > 0)
        {
            result.IsValid = false;
            return result;
        }

        if (lines.Count == 0)
        {
            result.Errors.Add("File Word không có nội dung hoặc rỗng.");
            result.IsValid = false;
            return result;
        }

        var examDto = new ToeicExamDto
        {
            Code = "TOEIC_READING_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"),
            Title = "Đề thi TOEIC Reading",
            DurationMinutes = 75,
            TotalQuestions = 100,
            Status = ToeicExamStatus.Published,
            IsActive = true,
            SourceFileName = fileName ?? "DeThi.docx",
            CreationTime = DateTime.Now
        };

        ToeicPartDto currentPart = null;
        ToeicPassageGroupDto currentPassageGroup = null;
        bool inPassage = false;
        var passageLines = new List<string>();

        ToeicQuestionDto currentQuestion = null;
        var questionPromptLines = new List<string>();
        int expectedQuestionNumber = 101;
        var questionsFound = new HashSet<int>();

        for (int i = 0; i < lines.Count; i++)
        {
            string line = lines[i].Trim();
            if (string.IsNullOrWhiteSpace(line)) continue;

            if (line == "[TEST]")
            {
                continue;
            }
            else if (line.StartsWith("[TITLE:", StringComparison.OrdinalIgnoreCase))
            {
                examDto.Title = ExtractTagValue(line, "TITLE");
            }
            else if (line.StartsWith("[TIME:", StringComparison.OrdinalIgnoreCase))
            {
                if (int.TryParse(ExtractTagValue(line, "TIME"), out int time))
                {
                    examDto.DurationMinutes = time;
                }
            }
            else if (line.StartsWith("[TOTAL_QUESTIONS:", StringComparison.OrdinalIgnoreCase))
            {
                if (int.TryParse(ExtractTagValue(line, "TOTAL_QUESTIONS"), out int totalQ))
                {
                    examDto.TotalQuestions = totalQ;
                }
            }
            else if (line.StartsWith("[PART:", StringComparison.OrdinalIgnoreCase))
            {
                if (int.TryParse(ExtractTagValue(line, "PART"), out int partNum))
                {
                    currentPart = new ToeicPartDto
                    {
                        PartNumber = partNum,
                        PartTitle = $"Part {partNum}",
                        OrderIndex = partNum
                    };
                    examDto.Parts.Add(currentPart);
                    currentPassageGroup = null;
                }
            }
            else if (line.StartsWith("[PART_TITLE:", StringComparison.OrdinalIgnoreCase))
            {
                if (currentPart != null)
                {
                    currentPart.PartTitle = ExtractTagValue(line, "PART_TITLE");
                }
            }
            else if (line.StartsWith("[DESCRIPTION:", StringComparison.OrdinalIgnoreCase))
            {
                if (currentPart != null)
                {
                    currentPart.Description = ExtractTagValue(line, "DESCRIPTION");
                }
            }
            else if (line.StartsWith("[PASSAGE_TITLE:", StringComparison.OrdinalIgnoreCase))
            {
                if (currentPart != null)
                {
                    currentPassageGroup = new ToeicPassageGroupDto
                    {
                        PartId = currentPart.PartNumber,
                        Title = ExtractTagValue(line, "PASSAGE_TITLE"),
                        OrderIndex = currentPart.PassageGroups.Count + 1
                    };
                    currentPart.PassageGroups.Add(currentPassageGroup);
                }
            }
            else if (line.Equals("[PASSAGE]", StringComparison.OrdinalIgnoreCase))
            {
                inPassage = true;
                passageLines.Clear();
                if (currentPassageGroup == null && currentPart != null)
                {
                    currentPassageGroup = new ToeicPassageGroupDto
                    {
                        PartId = currentPart.PartNumber,
                        Title = "Đoạn văn đọc hiểu",
                        OrderIndex = currentPart.PassageGroups.Count + 1
                    };
                    currentPart.PassageGroups.Add(currentPassageGroup);
                }
            }
            else if (line.Equals("[/PASSAGE]", StringComparison.OrdinalIgnoreCase))
            {
                inPassage = false;
                if (currentPassageGroup != null)
                {
                    currentPassageGroup.PassageText = string.Join("\n\n", passageLines);
                }
                passageLines.Clear();
            }
            else if (inPassage)
            {
                passageLines.Add(line);
            }
            else if (line.StartsWith("[QUESTION:", StringComparison.OrdinalIgnoreCase))
            {
                var match = Regex.Match(line, @"\[QUESTION:\s*(\d+)\]", RegexOptions.IgnoreCase);
                if (match.Success && int.TryParse(match.Groups[1].Value, out int qNum))
                {
                    if (questionsFound.Contains(qNum))
                    {
                        result.Errors.Add($"Phát hiện trùng lặp số câu hỏi: Câu {qNum} xuất hiện nhiều lần.");
                    }
                    questionsFound.Add(qNum);

                    if (qNum != expectedQuestionNumber)
                    {
                        result.Errors.Add($"Sai thứ tự câu: mong đợi câu {expectedQuestionNumber} nhưng lại gặp câu {qNum}.");
                    }
                    expectedQuestionNumber++;

                    if (currentPart == null)
                    {
                        result.Errors.Add($"Câu {qNum} không thuộc Part nào. Cần có thẻ [PART: X] trước câu hỏi.");
                    }

                    currentQuestion = new ToeicQuestionDto
                    {
                        QuestionNumber = qNum,
                        PartId = currentPart?.PartNumber ?? 5,
                        OrderIndex = qNum
                    };

                    if (currentPart != null)
                    {
                        if (currentPart.PartNumber == 5)
                        {
                            currentPart.Questions.Add(currentQuestion);
                        }
                        else
                        {
                            if (currentPassageGroup != null)
                            {
                                currentPassageGroup.Questions.Add(currentQuestion);
                            }
                            else
                            {
                                currentPart.Questions.Add(currentQuestion);
                            }
                        }
                    }

                    questionPromptLines.Clear();
                }
                else
                {
                    result.Errors.Add($"Định dạng thẻ câu hỏi không hợp lệ: '{line}'.");
                }
            }
            else if (line.StartsWith("[A]", StringComparison.OrdinalIgnoreCase))
            {
                AddOption(currentQuestion, "A", line.Substring(3).Trim(), result);
            }
            else if (line.StartsWith("[B]", StringComparison.OrdinalIgnoreCase))
            {
                AddOption(currentQuestion, "B", line.Substring(3).Trim(), result);
            }
            else if (line.StartsWith("[C]", StringComparison.OrdinalIgnoreCase))
            {
                AddOption(currentQuestion, "C", line.Substring(3).Trim(), result);
            }
            else if (line.StartsWith("[D]", StringComparison.OrdinalIgnoreCase))
            {
                AddOption(currentQuestion, "D", line.Substring(3).Trim(), result);
            }
            else if (line.StartsWith("[ANSWER:", StringComparison.OrdinalIgnoreCase))
            {
                string ans = ExtractTagValue(line, "ANSWER").ToUpperInvariant();
                if (currentQuestion != null)
                {
                    currentQuestion.CorrectOption = ans;
                    var correctOpt = currentQuestion.Options.FirstOrDefault(o => o.OptionKey.Equals(ans, StringComparison.OrdinalIgnoreCase));
                    if (correctOpt != null)
                    {
                        correctOpt.IsCorrect = true;
                    }
                    else
                    {
                        result.Errors.Add($"Câu {currentQuestion.QuestionNumber}: Đáp án đúng '{ans}' không trùng với bất kỳ đáp án A/B/C/D nào.");
                    }
                }
            }
            else if (line.Equals("[END_TEST]", StringComparison.OrdinalIgnoreCase))
            {
                break;
            }
            else
            {
                // If it's outside passage and before options, it's question text/prompt
                if (currentQuestion != null && currentQuestion.Options.Count == 0)
                {
                    questionPromptLines.Add(line);
                    currentQuestion.QuestionText = string.Join(" ", questionPromptLines);
                }
            }
        }

        // Post-validation checks
        if (inPassage)
        {
            result.Errors.Add("Thiếu thẻ đóng [/PASSAGE] cho bài đọc.");
        }

        if (examDto.Parts.Count == 0)
        {
            result.Errors.Add("Không tìm thấy phần thi nào ([PART: 5], [PART: 6], [PART: 7]).");
        }

        // Validate each question
        var allQuestions = examDto.Parts
            .SelectMany(p => p.Questions.Concat(p.PassageGroups.SelectMany(g => g.Questions)))
            .ToList();

        if (allQuestions.Count != 100)
        {
            result.Errors.Add($"Tổng số câu hỏi không đủ 100 câu TOEIC Reading: tìm thấy {allQuestions.Count} câu (yêu cầu từ 101 đến 200).");
        }

        foreach (var q in allQuestions)
        {
            if (q.Options.Count != 4)
            {
                result.Errors.Add($"Câu {q.QuestionNumber} có {q.Options.Count} lựa chọn (yêu cầu đủ 4 đáp án A, B, C, D).");
            }
            if (string.IsNullOrWhiteSpace(q.CorrectOption))
            {
                result.Errors.Add($"Câu {q.QuestionNumber} chưa có thẻ [ANSWER: X] chỉ định đáp án đúng.");
            }
        }

        result.ExamTitle = examDto.Title;
        result.DurationMinutes = examDto.DurationMinutes;
        result.TotalQuestions = allQuestions.Count;

        var part5 = examDto.Parts.FirstOrDefault(p => p.PartNumber == 5);
        var part6 = examDto.Parts.FirstOrDefault(p => p.PartNumber == 6);
        var part7 = examDto.Parts.FirstOrDefault(p => p.PartNumber == 7);

        result.Part5Count = part5?.Questions.Count ?? 0;
        result.Part6Count = part6?.PassageGroups.Sum(g => g.Questions.Count) ?? (part6?.Questions.Count ?? 0);
        result.Part7Count = part7?.PassageGroups.Sum(g => g.Questions.Count) ?? (part7?.Questions.Count ?? 0);

        if (result.Errors.Count == 0)
        {
            result.IsValid = true;
            result.PreviewData = examDto;
        }
        else
        {
            result.IsValid = false;
            result.PreviewData = null;
        }

        return result;
    }

    private List<string> ExtractParagraphs(Stream stream, ToeicValidationResultDto result)
    {
        var lines = new List<string>();
        try
        {
            using var archive = new ZipFileArchive(stream, ZipArchiveMode.Read, true);
            var entry = archive.GetEntry("word/document.xml");
            if (entry == null)
            {
                result.Errors.Add("File docx không hợp lệ (không tìm thấy word/document.xml).");
                return lines;
            }

            using var entryStream = entry.Open();
            var xDoc = XDocument.Load(entryStream);

            foreach (var p in xDoc.Descendants(W + "p"))
            {
                var textParts = new List<string>();
                foreach (var node in p.Descendants())
                {
                    if (node.Name == W + "t")
                    {
                        textParts.Add(node.Value);
                    }
                    else if (node.Name == W + "br")
                    {
                        textParts.Add("\n");
                    }
                }
                string pText = string.Concat(textParts).Trim();
                if (!string.IsNullOrWhiteSpace(pText))
                {
                    lines.Add(pText);
                }
            }
        }
        catch (Exception ex)
        {
            result.Errors.Add($"Lỗi khi giải nén và đọc file .docx: {ex.Message}");
        }
        return lines;
    }

    private string ExtractTagValue(string line, string tagName)
    {
        string prefix = $"[{tagName}:";
        if (line.StartsWith(prefix, StringComparison.OrdinalIgnoreCase) && line.EndsWith("]"))
        {
            return line.Substring(prefix.Length, line.Length - prefix.Length - 1).Trim();
        }
        return string.Empty;
    }

    private void AddOption(ToeicQuestionDto question, string optKey, string text, ToeicValidationResultDto result)
    {
        if (question == null)
        {
            result.Errors.Add($"Đáp án [{optKey}] xuất hiện bên ngoài câu hỏi.");
            return;
        }
        question.Options.Add(new ToeicQuestionOptionDto
        {
            OptionKey = optKey,
            OptionText = text,
            OrderIndex = question.Options.Count + 1
        });
    }

    // Helper wrapper for ZipArchive to handle stream lifetime properly
    private sealed class ZipFileArchive : ZipArchive
    {
        public ZipFileArchive(Stream stream, ZipArchiveMode mode, bool leaveOpen) : base(stream, mode, leaveOpen) { }
    }
}
