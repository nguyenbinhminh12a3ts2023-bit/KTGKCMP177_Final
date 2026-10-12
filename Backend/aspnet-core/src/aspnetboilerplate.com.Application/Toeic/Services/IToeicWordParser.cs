using Abp.Dependency;
using aspnetboilerplate.com.Toeic.Dto;
using System.IO;

namespace aspnetboilerplate.com.Toeic.Services;

public interface IToeicWordParser : ITransientDependency
{
    ToeicValidationResultDto ParseAndValidate(Stream docxStream, string fileName = null);
}
