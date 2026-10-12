using Abp.Authorization;
using Abp.Runtime.Session;
using aspnetboilerplate.com.Configuration.Dto;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Configuration;

[AbpAuthorize]
public class ConfigurationAppService : comAppServiceBase, IConfigurationAppService
{
    public async Task ChangeUiTheme(ChangeUiThemeInput input)
    {
        await SettingManager.ChangeSettingForUserAsync(AbpSession.ToUserIdentifier(), AppSettingNames.UiTheme, input.Theme);
    }
}
