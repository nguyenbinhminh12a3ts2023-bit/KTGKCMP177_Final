using Abp.Modules;
using Abp.Reflection.Extensions;
using aspnetboilerplate.com.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace aspnetboilerplate.com.Web.Host.Startup
{
    [DependsOn(
       typeof(comWebCoreModule))]
    public class comWebHostModule : AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public comWebHostModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(comWebHostModule).GetAssembly());
        }
    }
}
