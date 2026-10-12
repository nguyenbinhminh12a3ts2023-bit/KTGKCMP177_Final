using Abp.Application.Services;
using aspnetboilerplate.com.MultiTenancy.Dto;

namespace aspnetboilerplate.com.MultiTenancy;

public interface ITenantAppService : IAsyncCrudAppService<TenantDto, int, PagedTenantResultRequestDto, CreateTenantDto, TenantDto>
{
}

