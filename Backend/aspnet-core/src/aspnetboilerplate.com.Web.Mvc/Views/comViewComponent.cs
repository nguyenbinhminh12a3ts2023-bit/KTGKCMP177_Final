using Abp.AspNetCore.Mvc.ViewComponents;

namespace aspnetboilerplate.com.Web.Views;

public abstract class comViewComponent : AbpViewComponent
{
    protected comViewComponent()
    {
        LocalizationSourceName = comConsts.LocalizationSourceName;
    }
}
