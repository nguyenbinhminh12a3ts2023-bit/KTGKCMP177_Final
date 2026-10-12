using Abp.MultiTenancy;
using aspnetboilerplate.com.Authorization.Users;

namespace aspnetboilerplate.com.MultiTenancy;

public class Tenant : AbpTenant<User>
{
    public Tenant()
    {
    }

    public Tenant(string tenancyName, string name)
        : base(tenancyName, name)
    {
    }
}
