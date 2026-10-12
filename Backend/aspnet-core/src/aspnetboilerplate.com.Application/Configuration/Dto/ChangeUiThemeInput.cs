using System.ComponentModel.DataAnnotations;

namespace aspnetboilerplate.com.Configuration.Dto;

public class ChangeUiThemeInput
{
    [Required]
    [StringLength(32)]
    public string Theme { get; set; }
}
