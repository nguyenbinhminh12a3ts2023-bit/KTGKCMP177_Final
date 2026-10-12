using System.ComponentModel.DataAnnotations;

namespace aspnetboilerplate.com.Users.Dto;

public class ChangeUserLanguageDto
{
    [Required]
    public string LanguageName { get; set; }
}