using Abp.Application.Services;
using aspnetboilerplate.com.Sessions.Dto;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Sessions;

public interface ISessionAppService : IApplicationService
{
    Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();
}
