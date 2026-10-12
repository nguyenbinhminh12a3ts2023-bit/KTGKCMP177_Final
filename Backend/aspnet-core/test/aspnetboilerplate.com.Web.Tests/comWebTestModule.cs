using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using aspnetboilerplate.com.EntityFrameworkCore;
using aspnetboilerplate.com.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace aspnetboilerplate.com.Web.Tests;

[DependsOn(
    typeof(comWebMvcModule),
    typeof(AbpAspNetCoreTestBaseModule)
)]
public class comWebTestModule : AbpModule
{
    public comWebTestModule(comEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
    }

    public override void PreInitialize()
    {
        Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(comWebTestModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        IocManager.Resolve<ApplicationPartManager>()
            .AddApplicationPartsIfNotAddedBefore(typeof(comWebMvcModule).Assembly);
    }
}