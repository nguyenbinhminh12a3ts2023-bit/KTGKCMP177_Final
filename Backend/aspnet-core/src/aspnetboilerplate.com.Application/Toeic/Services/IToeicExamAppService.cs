using Abp.Application.Services;
using aspnetboilerplate.com.Toeic.Dto;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Toeic.Services;

public interface IToeicExamAppService : IApplicationService
{
    Task<ToeicValidationResultDto> ValidateDocxAsync(IFormFile file);
    Task<ToeicExamDto> ImportDocxAsync(IFormFile file);
    Task<ToeicExamDto> SeedSampleExamAsync();
    Task<List<ToeicExamDto>> GetAllExamsAsync();
    Task<ToeicExamDto> GetExamDetailForAdminAsync(int examId);
    Task<ToeicExamDto> GetExamForStudentAsync(int examId);
    Task<ToeicExamDto> UpdateExamAsync(UpdateExamDto input);
    Task DeleteExamAsync(int examId);
    Task<ToeicSessionResultDto> StartExamSessionAsync(StartExamSessionDto input);
    Task<ToeicSessionResultDto> SubmitExamSessionAsync(SubmitExamSessionDto input);
    Task<ToeicSessionResultDto> GetSessionResultAsync(long sessionId);
}
