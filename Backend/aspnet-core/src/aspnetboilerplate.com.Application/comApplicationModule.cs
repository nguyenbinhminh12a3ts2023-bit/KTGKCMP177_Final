using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;
using aspnetboilerplate.com.Authorization;

namespace aspnetboilerplate.com;

[DependsOn(
    typeof(comCoreModule),
    typeof(AbpAutoMapperModule))]
public class comApplicationModule : AbpModule
{
    public override void PreInitialize()
    {
        Configuration.Authorization.Providers.Add<comAuthorizationProvider>();
    }

    public override void Initialize()
    {
        var thisAssembly = typeof(comApplicationModule).GetAssembly();

        IocManager.RegisterAssemblyByConvention(thisAssembly);

        Configuration.Modules.AbpAutoMapper().Configurators.Add(
            // Scan the assembly for classes which inherit from AutoMapper.Profile
            cfg => cfg.AddMaps(thisAssembly)
        );
    }
}
