using Abp.Application.Services;
using aspnetboilerplate.com.Authorization.Accounts.Dto;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Authorization.Accounts;

public interface IAccountAppService : IApplicationService
{
    Task<IsTenantAvailableOutput> IsTenantAvailable(IsTenantAvailableInput input);

    Task<RegisterOutput> Register(RegisterInput input);
}
