using Abp.AspNetCore.Mvc.Controllers;
using aspnetboilerplate.com.Controllers;
using aspnetboilerplate.com.Toeic.Dto;
using aspnetboilerplate.com.Toeic.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Web.Host.Controllers
{
    [Route("api/toeic")]
    [ApiController]
    public class ToeicExamController : comControllerBase
    {
        private readonly IToeicExamAppService _toeicAppService;

        public ToeicExamController(IToeicExamAppService toeicAppService)
        {
            _toeicAppService = toeicAppService;
        }

        /// <summary>
        /// Kiểm tra tính hợp lệ của file Word .docx mà không lưu CSDL
        /// </summary>
        [HttpPost("upload-validate")]
        public async Task<ActionResult<ToeicValidationResultDto>> UploadAndValidate(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new ToeicValidationResultDto
                {
                    IsValid = false,
                    Errors = new List<string> { "Vui lòng chọn file .docx hợp lệ." }
                });
            }

            var result = await _toeicAppService.ValidateDocxAsync(file);
            return Ok(result);
        }

        /// <summary>
        /// Import đề thi từ file Word .docx vào CSDL MSSQL (chỉ lưu khi đúng 100% chuẩn)
        /// </summary>
        [HttpPost("import")]
        public async Task<ActionResult<ToeicExamDto>> ImportExam(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest("Vui lòng đính kèm file .docx.");
            }

            var exam = await _toeicAppService.ImportDocxAsync(file);
            return Ok(exam);
        }

        /// <summary>
        /// Nạp đề thi mẫu DeThiGiuaKy_Reading_v07.docx vào hệ thống
        /// </summary>
        [HttpGet("seed")]
        public async Task<ActionResult<ToeicExamDto>> SeedSampleExam()
        {
            var exam = await _toeicAppService.SeedSampleExamAsync();
            return Ok(exam);
        }

        /// <summary>
        /// Lấy danh sách tất cả đề thi
        /// </summary>
        [HttpGet("exams")]
        public async Task<ActionResult<List<ToeicExamDto>>> GetAllExams()
        {
            var exams = await _toeicAppService.GetAllExamsAsync();
            return Ok(exams);
        }

        /// <summary>
        /// Lấy chi tiết đề thi cho Quản trị viên (đầy đủ đáp án đúng, giải thích)
        /// </summary>
        [HttpGet("exams/{id}/detail")]
        public async Task<ActionResult<ToeicExamDto>> GetExamDetailForAdmin(int id)
        {
            var exam = await _toeicAppService.GetExamDetailForAdminAsync(id);
            return Ok(exam);
        }

        /// <summary>
        /// Lấy đề thi cho Thí sinh làm bài (ẩn đáp án đúng)
        /// </summary>
        [HttpGet("exams/{id}/student")]
        public async Task<ActionResult<ToeicExamDto>> GetExamForStudent(int id)
        {
            var exam = await _toeicAppService.GetExamForStudentAsync(id);
            return Ok(exam);
        }

        /// <summary>
        /// Cập nhật nội dung đề thi, câu hỏi, đoạn văn
        /// </summary>
        [HttpPut("exams/{id}")]
        public async Task<ActionResult<ToeicExamDto>> UpdateExam(int id, [FromBody] UpdateExamDto input)
        {
            input.Id = id;
            var updated = await _toeicAppService.UpdateExamAsync(input);
            return Ok(updated);
        }

        /// <summary>
        /// Xóa đề thi
        /// </summary>
        [HttpDelete("exams/{id}")]
        public async Task<IActionResult> DeleteExam(int id)
        {
            await _toeicAppService.DeleteExamAsync(id);
            return NoContent();
        }

        /// <summary>
        /// Bắt đầu phiên làm bài thi cho thí sinh
        /// </summary>
        [HttpPost("sessions/start")]
        public async Task<ActionResult<ToeicSessionResultDto>> StartSession([FromBody] StartExamSessionDto input)
        {
            var session = await _toeicAppService.StartExamSessionAsync(input);
            return Ok(session);
        }

        /// <summary>
        /// Nộp bài thi và chấm điểm tự động
        /// </summary>
        [HttpPost("sessions/submit")]
        public async Task<ActionResult<ToeicSessionResultDto>> SubmitSession([FromBody] SubmitExamSessionDto input)
        {
            var result = await _toeicAppService.SubmitExamSessionAsync(input);
            return Ok(result);
        }

        /// <summary>
        /// Xem kết quả bài thi chi tiết
        /// </summary>
        [HttpGet("sessions/{id}/result")]
        public async Task<ActionResult<ToeicSessionResultDto>> GetSessionResult(long id)
        {
            var result = await _toeicAppService.GetSessionResultAsync(id);
            return Ok(result);
        }
    }
}
