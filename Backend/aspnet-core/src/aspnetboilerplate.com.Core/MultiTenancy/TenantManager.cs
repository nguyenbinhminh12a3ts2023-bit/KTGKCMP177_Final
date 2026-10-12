using Abp.Application.Features;
using Abp.Domain.Repositories;
using Abp.MultiTenancy;
using aspnetboilerplate.com.Authorization.Users;
using aspnetboilerplate.com.Editions;

namespace aspnetboilerplate.com.MultiTenancy;

public class TenantManager : AbpTenantManager<Tenant, User>
{
    public TenantManager(
        IRepository<Tenant> tenantRepository,
        IRepository<TenantFeatureSetting, long> tenantFeatureRepository,
        EditionManager editionManager,
        IAbpZeroFeatureValueStore featureValueStore)
        : base(
            tenantRepository,
            tenantFeatureRepository,
            editionManager,
            featureValueStore)
    {
    }
}
