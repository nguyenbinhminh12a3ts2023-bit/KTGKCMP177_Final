using aspnetboilerplate.com.Configuration.Dto;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Configuration;

public interface IConfigurationAppService
{
    Task ChangeUiTheme(ChangeUiThemeInput input);
}
