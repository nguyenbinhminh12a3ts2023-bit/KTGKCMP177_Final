using Abp.MultiTenancy;
using System.ComponentModel.DataAnnotations;

namespace aspnetboilerplate.com.Authorization.Accounts.Dto;

public class IsTenantAvailableInput
{
    [Required]
    [StringLength(AbpTenantBase.MaxTenancyNameLength)]
    public string TenancyName { get; set; }
}
