using Abp.AspNetCore.Mvc.Views;
using Abp.Runtime.Session;
using Microsoft.AspNetCore.Mvc.Razor.Internal;

namespace aspnetboilerplate.com.Web.Views;

public abstract class comRazorPage<TModel> : AbpRazorPage<TModel>
{
    [RazorInject]
    public IAbpSession AbpSession { get; set; }

    protected comRazorPage()
    {
        LocalizationSourceName = comConsts.LocalizationSourceName;
    }
}
