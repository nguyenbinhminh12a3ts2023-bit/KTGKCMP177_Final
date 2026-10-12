using Abp.AspNetCore.Mvc.Controllers;
using Abp.IdentityFramework;
using Microsoft.AspNetCore.Identity;

namespace aspnetboilerplate.com.Controllers
{
    public abstract class comControllerBase : AbpController
    {
        protected comControllerBase()
        {
            LocalizationSourceName = comConsts.LocalizationSourceName;
        }

        protected void CheckErrors(IdentityResult identityResult)
        {
            identityResult.CheckErrors(LocalizationManager);
        }
    }
}
