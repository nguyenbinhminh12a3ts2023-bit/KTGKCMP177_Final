using Abp.Application.Services;
using Abp.Domain.Repositories;
using Abp.UI;
using aspnetboilerplate.com.Toeic.Dto;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Toeic.Services;

public class ToeicExamAppService : ApplicationService, IToeicExamAppService
{
    private readonly IRepository<ToeicExam> _examRepository;
    private readonly IRepository<ToeicPart> _partRepository;
    private readonly IRepository<ToeicPassageGroup> _passageGroupRepository;
    private readonly IRepository<ToeicQuestion> _questionRepository;
    private readonly IRepository<ToeicQuestionOption> _optionRepository;
    private readonly IRepository<ToeicExamSession, long> _sessionRepository;
    private readonly IRepository<ToeicExamAnswer, long> _answerRepository;
    private readonly IToeicWordParser _wordParser;

    public ToeicExamAppService(
        IRepository<ToeicExam> examRepository,
        IRepository<ToeicPart> partRepository,
        IRepository<ToeicPassageGroup> passageGroupRepository,
        IRepository<ToeicQuestion> questionRepository,
        IRepository<ToeicQuestionOption> optionRepository,
        IRepository<ToeicExamSession, long> sessionRepository,
        IRepository<ToeicExamAnswer, long> answerRepository,
        IToeicWordParser wordParser)
    {
        _examRepository = examRepository;
        _partRepository = partRepository;
        _passageGroupRepository = passageGroupRepository;
        _questionRepository = questionRepository;
        _optionRepository = optionRepository;
        _sessionRepository = sessionRepository;
        _answerRepository = answerRepository;
        _wordParser = wordParser;
    }

    public async Task<ToeicValidationResultDto> ValidateDocxAsync(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return new ToeicValidationResultDto
            {
                IsValid = false,
                Errors = new List<string> { "Vui lòng chọn file Word (.docx) để kiểm tra." }
            };
        }

        using var memoryStream = new MemoryStream();
        await file.CopyToAsync(memoryStream);
        memoryStream.Position = 0;

        return _wordParser.ParseAndValidate(memoryStream, file.FileName);
    }

    public async Task<ToeicExamDto> ImportDocxAsync(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            throw new UserFriendlyException("File không được rỗng.");
        }

        using var memoryStream = new MemoryStream();
        await file.CopyToAsync(memoryStream);
        memoryStream.Position = 0;

        var validationResult = _wordParser.ParseAndValidate(memoryStream, file.FileName);
        if (!validationResult.IsValid)
        {
            string errorDetails = string.Join("\n", validationResult.Errors.Take(10));
            throw new UserFriendlyException($"File không đạt chuẩn 100%. Đã hủy toàn bộ và không lưu vào CSDL:\n{errorDetails}");
        }

        return await SaveExamFromDtoAsync(validationResult.PreviewData);
    }

    public async Task<ToeicExamDto> SeedSampleExamAsync()
    {
        var existing = await _examRepository.GetAll()
            .Include(e => e.Parts)
            .FirstOrDefaultAsync(e => e.IsActive);

        if (existing != null)
        {
            return await GetExamDetailForAdminAsync(existing.Id);
        }

        // Try reading DeThiGiuaKy_Reading_v07.docx
        string docxPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "..", "..", "DeThiGiuaKy_Reading_v07.docx");
        docxPath = Path.GetFullPath(docxPath);

        if (!File.Exists(docxPath))
        {
            docxPath = @"d:\KTGK_Final\DeThiGiuaKy_Reading_v07.docx";
        }

        if (File.Exists(docxPath))
        {
            using var fileStream = File.OpenRead(docxPath);
            var validationResult = _wordParser.ParseAndValidate(fileStream, Path.GetFileName(docxPath));
            if (validationResult.IsValid && validationResult.PreviewData != null)
            {
                return await SaveExamFromDtoAsync(validationResult.PreviewData);
            }
        }

        throw new UserFriendlyException("Không tìm thấy file mẫu DeThiGiuaKy_Reading_v07.docx để nạp dữ liệu.");
    }

    public async Task<List<ToeicExamDto>> GetAllExamsAsync()
    {
        var exams = await _examRepository.GetAllListAsync();
        return exams.Select(e => new ToeicExamDto
        {
            Id = e.Id,
            Code = e.Code,
            Title = e.Title,
            Description = e.Description,
            DurationMinutes = e.DurationMinutes,
            TotalQuestions = e.TotalQuestions,
            Status = e.Status,
            IsActive = e.IsActive,
            SourceFileName = e.SourceFileName,
            CreationTime = e.CreationTime
        }).OrderByDescending(e => e.Id).ToList();
    }

    public async Task<ToeicExamDto> GetExamDetailForAdminAsync(int examId)
    {
        var exam = await _examRepository.GetAll()
            .Include(e => e.Parts)
                .ThenInclude(p => p.PassageGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
            .Include(e => e.Parts)
                .ThenInclude(p => p.Questions)
                    .ThenInclude(q => q.Options)
            .FirstOrDefaultAsync(e => e.Id == examId);

        if (exam == null)
        {
            throw new UserFriendlyException($"Không tìm thấy đề thi với Id = {examId}");
        }

        return MapToExamDto(exam, includeAnswers: true);
    }

    public async Task<ToeicExamDto> GetExamForStudentAsync(int examId)
    {
        var exam = await _examRepository.GetAll()
            .Include(e => e.Parts)
                .ThenInclude(p => p.PassageGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
            .Include(e => e.Parts)
                .ThenInclude(p => p.Questions)
                    .ThenInclude(q => q.Options)
            .FirstOrDefaultAsync(e => e.Id == examId);

        if (exam == null)
        {
            throw new UserFriendlyException($"Không tìm thấy đề thi với Id = {examId}");
        }

        return MapToExamDto(exam, includeAnswers: false);
    }

    public async Task<ToeicExamDto> UpdateExamAsync(UpdateExamDto input)
    {
        var exam = await _examRepository.GetAll()
            .Include(e => e.Parts)
                .ThenInclude(p => p.PassageGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
            .Include(e => e.Parts)
                .ThenInclude(p => p.Questions)
                    .ThenInclude(q => q.Options)
            .FirstOrDefaultAsync(e => e.Id == input.Id);

        if (exam == null)
        {
            throw new UserFriendlyException($"Không tìm thấy đề thi với Id = {input.Id}");
        }

        if (!string.IsNullOrWhiteSpace(input.Title)) exam.Title = input.Title;
        if (!string.IsNullOrWhiteSpace(input.Description)) exam.Description = input.Description;
        if (input.DurationMinutes > 0) exam.DurationMinutes = input.DurationMinutes;

        if (input.Parts != null)
        {
            foreach (var partDto in input.Parts)
            {
                var part = exam.Parts.FirstOrDefault(p => p.Id == partDto.Id || p.PartNumber == partDto.PartNumber);
                if (part != null)
                {
                    if (!string.IsNullOrWhiteSpace(partDto.PartTitle)) part.PartTitle = partDto.PartTitle;
                    if (!string.IsNullOrWhiteSpace(partDto.Description)) part.Description = partDto.Description;

                    // Update passage groups
                    foreach (var groupDto in partDto.PassageGroups)
                    {
                        var group = part.PassageGroups.FirstOrDefault(g => g.Id == groupDto.Id);
                        if (group != null)
                        {
                            group.Title = groupDto.Title;
                            group.PassageText = groupDto.PassageText;
                        }

                        foreach (var qDto in groupDto.Questions)
                        {
                            var q = group?.Questions.FirstOrDefault(x => x.Id == qDto.Id || x.QuestionNumber == qDto.QuestionNumber);
                            if (q != null)
                            {
                                UpdateQuestionFields(q, qDto);
                            }
                        }
                    }

                    // Update independent questions
                    foreach (var qDto in partDto.Questions)
                    {
                        var q = part.Questions.FirstOrDefault(x => x.Id == qDto.Id || x.QuestionNumber == qDto.QuestionNumber);
                        if (q != null)
                        {
                            UpdateQuestionFields(q, qDto);
                        }
                    }
                }
            }
        }

        await _examRepository.UpdateAsync(exam);
        return await GetExamDetailForAdminAsync(exam.Id);
    }

    public async Task DeleteExamAsync(int examId)
    {
        var exam = await _examRepository.FirstOrDefaultAsync(examId);
        if (exam != null)
        {
            await _examRepository.DeleteAsync(exam);
        }
    }

    public async Task<ToeicSessionResultDto> StartExamSessionAsync(StartExamSessionDto input)
    {
        var exam = await _examRepository.FirstOrDefaultAsync(input.ExamId);
        if (exam == null)
        {
            throw new UserFriendlyException($"Đề thi không tồn tại.");
        }

        var session = new ToeicExamSession
        {
            ExamId = input.ExamId,
            CandidateName = string.IsNullOrWhiteSpace(input.CandidateName) ? "Thí sinh tự do" : input.CandidateName.Trim(),
            CandidateCode = string.IsNullOrWhiteSpace(input.CandidateCode) ? ("TS_" + DateTime.Now.ToString("HHmmss")) : input.CandidateCode.Trim(),
            StartTime = DateTime.Now,
            TotalQuestions = exam.TotalQuestions,
            Status = ToeicSessionStatus.InProgress
        };

        long sessionId = await _sessionRepository.InsertAndGetIdAsync(session);

        return new ToeicSessionResultDto
        {
            SessionId = sessionId,
            ExamId = exam.Id,
            ExamTitle = exam.Title,
            CandidateName = session.CandidateName,
            CandidateCode = session.CandidateCode,
            StartTime = session.StartTime,
            TotalQuestions = exam.TotalQuestions,
            Status = session.Status.ToString()
        };
    }

    public async Task<ToeicSessionResultDto> SubmitExamSessionAsync(SubmitExamSessionDto input)
    {
        var session = await _sessionRepository.GetAll()
            .Include(s => s.Exam)
            .FirstOrDefaultAsync(s => s.Id == input.SessionId);

        if (session == null)
        {
            throw new UserFriendlyException("Phiên thi không tồn tại.");
        }

        // Fetch all questions for this exam
        var questions = await _questionRepository.GetAll()
            .Include(q => q.Part)
            .Where(q => q.Part.ExamId == session.ExamId)
            .ToListAsync();

        int correctCount = 0;
        int wrongCount = 0;
        int unansweredCount = 0;
        var reviewList = new List<AnswerReviewItemDto>();

        var answersDict = input.Answers?
            .GroupBy(a => a.QuestionNumber)
            .ToDictionary(g => g.Key, g => g.First())
            ?? new Dictionary<int, SubmitAnswerItemDto>();

        foreach (var q in questions.OrderBy(q => q.QuestionNumber))
        {
            string selectedOpt = null;
            if (answersDict.TryGetValue(q.QuestionNumber, out var answerItem) && !string.IsNullOrWhiteSpace(answerItem.SelectedOption))
            {
                selectedOpt = answerItem.SelectedOption.Trim().ToUpperInvariant();
            }

            bool isCorrect = false;
            if (string.IsNullOrWhiteSpace(selectedOpt))
            {
                unansweredCount++;
            }
            else
            {
                if (selectedOpt.Equals(q.CorrectOption, StringComparison.OrdinalIgnoreCase))
                {
                    correctCount++;
                    isCorrect = true;
                }
                else
                {
                    wrongCount++;
                }
            }

            var record = new ToeicExamAnswer
            {
                SessionId = session.Id,
                QuestionId = q.Id,
                QuestionNumber = q.QuestionNumber,
                SelectedOption = selectedOpt,
                CorrectOption = q.CorrectOption,
                IsCorrect = isCorrect
            };
            await _answerRepository.InsertAsync(record);

            reviewList.Add(new AnswerReviewItemDto
            {
                QuestionNumber = q.QuestionNumber,
                QuestionText = q.QuestionText,
                SelectedOption = selectedOpt,
                CorrectOption = q.CorrectOption,
                IsCorrect = isCorrect,
                Explanation = q.Explanation,
                PartNumber = q.Part?.PartNumber ?? 5
            });
        }

        session.EndTime = DateTime.Now;
        session.TimeSpentSeconds = input.TimeSpentSeconds;
        session.CorrectAnswersCount = correctCount;
        session.WrongAnswersCount = wrongCount;
        session.UnansweredCount = unansweredCount;
        session.Score = ToeicScoreCalculator.CalculateReadingScore(correctCount);
        session.Status = ToeicSessionStatus.Submitted;

        await _sessionRepository.UpdateAsync(session);

        double accuracy = questions.Count > 0 ? Math.Round((double)correctCount / questions.Count * 100.0, 1) : 0.0;

        return new ToeicSessionResultDto
        {
            SessionId = session.Id,
            ExamId = session.ExamId,
            ExamTitle = session.Exam?.Title,
            CandidateName = session.CandidateName,
            CandidateCode = session.CandidateCode,
            StartTime = session.StartTime,
            EndTime = session.EndTime,
            TimeSpentSeconds = session.TimeSpentSeconds,
            TotalQuestions = questions.Count,
            CorrectAnswersCount = correctCount,
            WrongAnswersCount = wrongCount,
            UnansweredCount = unansweredCount,
            Score = session.Score,
            AccuracyPercent = accuracy,
            Status = session.Status.ToString(),
            ReviewList = reviewList
        };
    }

    public async Task<ToeicSessionResultDto> GetSessionResultAsync(long sessionId)
    {
        var session = await _sessionRepository.GetAll()
            .Include(s => s.Exam)
            .Include(s => s.Answers)
                .ThenInclude(a => a.Question)
                    .ThenInclude(q => q.Part)
            .FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null)
        {
            throw new UserFriendlyException("Không tìm thấy kết quả phiên thi.");
        }

        var reviewList = session.Answers
            .OrderBy(a => a.QuestionNumber)
            .Select(a => new AnswerReviewItemDto
            {
                QuestionNumber = a.QuestionNumber,
                QuestionText = a.Question?.QuestionText,
                SelectedOption = a.SelectedOption,
                CorrectOption = a.CorrectOption,
                IsCorrect = a.IsCorrect,
                Explanation = a.Question?.Explanation,
                PartNumber = a.Question?.Part?.PartNumber ?? 5
            }).ToList();

        double accuracy = session.TotalQuestions > 0 ? Math.Round((double)session.CorrectAnswersCount / session.TotalQuestions * 100.0, 1) : 0.0;

        return new ToeicSessionResultDto
        {
            SessionId = session.Id,
            ExamId = session.ExamId,
            ExamTitle = session.Exam?.Title,
            CandidateName = session.CandidateName,
            CandidateCode = session.CandidateCode,
            StartTime = session.StartTime,
            EndTime = session.EndTime,
            TimeSpentSeconds = session.TimeSpentSeconds,
            TotalQuestions = session.TotalQuestions,
            CorrectAnswersCount = session.CorrectAnswersCount,
            WrongAnswersCount = session.WrongAnswersCount,
            UnansweredCount = session.UnansweredCount,
            Score = session.Score,
            AccuracyPercent = accuracy,
            Status = session.Status.ToString(),
            ReviewList = reviewList
        };
    }

    private void UpdateQuestionFields(ToeicQuestion q, ToeicQuestionDto qDto)
    {
        if (!string.IsNullOrWhiteSpace(qDto.QuestionText)) q.QuestionText = qDto.QuestionText;
        if (!string.IsNullOrWhiteSpace(qDto.CorrectOption))
        {
            q.CorrectOption = qDto.CorrectOption.ToUpperInvariant();
        }
        if (!string.IsNullOrWhiteSpace(qDto.Explanation)) q.Explanation = qDto.Explanation;

        if (qDto.Options != null)
        {
            foreach (var optDto in qDto.Options)
            {
                var opt = q.Options.FirstOrDefault(o => o.OptionKey.Equals(optDto.OptionKey, StringComparison.OrdinalIgnoreCase));
                if (opt != null)
                {
                    if (!string.IsNullOrWhiteSpace(optDto.OptionText)) opt.OptionText = optDto.OptionText;
                    opt.IsCorrect = opt.OptionKey.Equals(q.CorrectOption, StringComparison.OrdinalIgnoreCase);
                }
            }
        }
    }

    private async Task<ToeicExamDto> SaveExamFromDtoAsync(ToeicExamDto dto)
    {
        var exam = new ToeicExam
        {
            Code = dto.Code ?? ("TOEIC_" + DateTime.Now.ToString("yyyyMMdd_HHmmss")),
            Title = dto.Title,
            Description = dto.Description,
            DurationMinutes = dto.DurationMinutes,
            TotalQuestions = dto.TotalQuestions,
            Status = dto.Status,
            IsActive = true,
            SourceFileName = dto.SourceFileName
        };

        foreach (var pDto in dto.Parts)
        {
            var part = new ToeicPart
            {
                PartNumber = pDto.PartNumber,
                PartTitle = pDto.PartTitle,
                Description = pDto.Description,
                OrderIndex = pDto.OrderIndex
            };

            foreach (var gDto in pDto.PassageGroups)
            {
                var group = new ToeicPassageGroup
                {
                    Title = gDto.Title,
                    PassageText = gDto.PassageText,
                    PassageImageUrl = gDto.PassageImageUrl,
                    OrderIndex = gDto.OrderIndex
                };

                foreach (var qDto in gDto.Questions)
                {
                    var question = new ToeicQuestion
                    {
                        Part = part,
                        PassageGroup = group,
                        QuestionNumber = qDto.QuestionNumber,
                        QuestionText = qDto.QuestionText,
                        CorrectOption = qDto.CorrectOption,
                        Explanation = qDto.Explanation,
                        OrderIndex = qDto.OrderIndex
                    };

                    foreach (var oDto in qDto.Options)
                    {
                        question.Options.Add(new ToeicQuestionOption
                        {
                            OptionKey = oDto.OptionKey,
                            OptionText = oDto.OptionText,
                            IsCorrect = oDto.IsCorrect,
                            OrderIndex = oDto.OrderIndex
                        });
                    }

                    group.Questions.Add(question);
                    part.Questions.Add(question);
                }

                part.PassageGroups.Add(group);
            }

            foreach (var qDto in pDto.Questions)
            {
                var question = new ToeicQuestion
                {
                    Part = part,
                    QuestionNumber = qDto.QuestionNumber,
                    QuestionText = qDto.QuestionText,
                    CorrectOption = qDto.CorrectOption,
                    Explanation = qDto.Explanation,
                    OrderIndex = qDto.OrderIndex
                };

                foreach (var oDto in qDto.Options)
                {
                    question.Options.Add(new ToeicQuestionOption
                    {
                        OptionKey = oDto.OptionKey,
                        OptionText = oDto.OptionText,
                        IsCorrect = oDto.IsCorrect,
                        OrderIndex = oDto.OrderIndex
                    });
                }

                part.Questions.Add(question);
            }

            exam.Parts.Add(part);
        }

        await _examRepository.InsertAsync(exam);
        await CurrentUnitOfWork.SaveChangesAsync();

        return await GetExamDetailForAdminAsync(exam.Id);
    }

    private ToeicExamDto MapToExamDto(ToeicExam exam, bool includeAnswers)
    {
        return new ToeicExamDto
        {
            Id = exam.Id,
            Code = exam.Code,
            Title = exam.Title,
            Description = exam.Description,
            DurationMinutes = exam.DurationMinutes,
            TotalQuestions = exam.TotalQuestions,
            Status = exam.Status,
            IsActive = exam.IsActive,
            SourceFileName = exam.SourceFileName,
            CreationTime = exam.CreationTime,
            Parts = exam.Parts.OrderBy(p => p.PartNumber).Select(p => new ToeicPartDto
            {
                Id = p.Id,
                ExamId = p.ExamId,
                PartNumber = p.PartNumber,
                PartTitle = p.PartTitle,
                Description = p.Description,
                OrderIndex = p.OrderIndex,
                PassageGroups = p.PassageGroups.OrderBy(g => g.OrderIndex).Select(g => new ToeicPassageGroupDto
                {
                    Id = g.Id,
                    PartId = g.PartId,
                    Title = g.Title,
                    PassageText = g.PassageText,
                    PassageImageUrl = g.PassageImageUrl,
                    OrderIndex = g.OrderIndex,
                    Questions = g.Questions.OrderBy(q => q.QuestionNumber).Select(q => new ToeicQuestionDto
                    {
                        Id = q.Id,
                        PartId = q.PartId,
                        PassageGroupId = q.PassageGroupId,
                        QuestionNumber = q.QuestionNumber,
                        QuestionText = q.QuestionText,
                        CorrectOption = includeAnswers ? q.CorrectOption : null,
                        Explanation = includeAnswers ? q.Explanation : null,
                        OrderIndex = q.OrderIndex,
                        Options = q.Options.OrderBy(o => o.OptionKey).Select(o => new ToeicQuestionOptionDto
                        {
                            Id = o.Id,
                            QuestionId = o.QuestionId,
                            OptionKey = o.OptionKey,
                            OptionText = o.OptionText,
                            IsCorrect = includeAnswers && o.IsCorrect,
                            OrderIndex = o.OrderIndex
                        }).ToList()
                    }).ToList()
                }).ToList(),
                Questions = p.Questions.OrderBy(q => q.QuestionNumber).Select(q => new ToeicQuestionDto
                {
                    Id = q.Id,
                    PartId = q.PartId,
                    PassageGroupId = q.PassageGroupId,
                    QuestionNumber = q.QuestionNumber,
                    QuestionText = q.QuestionText,
                    CorrectOption = includeAnswers ? q.CorrectOption : null,
                    Explanation = includeAnswers ? q.Explanation : null,
                    OrderIndex = q.OrderIndex,
                    Options = q.Options.OrderBy(o => o.OptionKey).Select(o => new ToeicQuestionOptionDto
                    {
                        Id = o.Id,
                        QuestionId = o.QuestionId,
                        OptionKey = o.OptionKey,
                        OptionText = o.OptionText,
                        IsCorrect = includeAnswers && o.IsCorrect,
                        OrderIndex = o.OrderIndex
                    }).ToList()
                }).ToList()
            }).ToList()
        };
    }
}
