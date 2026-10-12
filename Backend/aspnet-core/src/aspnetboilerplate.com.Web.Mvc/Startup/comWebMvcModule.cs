using Abp.Modules;
using Abp.Reflection.Extensions;
using aspnetboilerplate.com.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace aspnetboilerplate.com.Web.Startup;

[DependsOn(typeof(comWebCoreModule))]
public class comWebMvcModule : AbpModule
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfigurationRoot _appConfiguration;

    public comWebMvcModule(IWebHostEnvironment env)
    {
        _env = env;
        _appConfiguration = env.GetAppConfiguration();
    }

    public override void PreInitialize()
    {
        Configuration.Navigation.Providers.Add<comNavigationProvider>();
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(comWebMvcModule).GetAssembly());
    }
}
