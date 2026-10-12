using Abp.Events.Bus;
using Abp.Modules;
using Abp.Reflection.Extensions;
using aspnetboilerplate.com.Configuration;
using aspnetboilerplate.com.EntityFrameworkCore;
using aspnetboilerplate.com.Migrator.DependencyInjection;
using Castle.MicroKernel.Registration;
using Microsoft.Extensions.Configuration;

namespace aspnetboilerplate.com.Migrator;

[DependsOn(typeof(comEntityFrameworkModule))]
public class comMigratorModule : AbpModule
{
    private readonly IConfigurationRoot _appConfiguration;

    public comMigratorModule(comEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbSeed = true;

        _appConfiguration = AppConfigurations.Get(
            typeof(comMigratorModule).GetAssembly().GetDirectoryPathOrNull()
        );
    }

    public override void PreInitialize()
    {
        Configuration.DefaultNameOrConnectionString = _appConfiguration.GetConnectionString(
            comConsts.ConnectionStringName
        );

        Configuration.BackgroundJobs.IsJobExecutionEnabled = false;
        Configuration.ReplaceService(
            typeof(IEventBus),
            () => IocManager.IocContainer.Register(
                Component.For<IEventBus>().Instance(NullEventBus.Instance)
            )
        );
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(comMigratorModule).GetAssembly());
        ServiceCollectionRegistrar.Register(IocManager);
    }
}
