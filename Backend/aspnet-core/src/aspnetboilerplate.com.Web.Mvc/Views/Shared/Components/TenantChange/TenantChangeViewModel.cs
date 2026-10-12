using Abp.AutoMapper;
using aspnetboilerplate.com.Sessions.Dto;

namespace aspnetboilerplate.com.Web.Views.Shared.Components.TenantChange;

[AutoMapFrom(typeof(GetCurrentLoginInformationsOutput))]
public class TenantChangeViewModel
{
    public TenantLoginInfoDto Tenant { get; set; }
}
