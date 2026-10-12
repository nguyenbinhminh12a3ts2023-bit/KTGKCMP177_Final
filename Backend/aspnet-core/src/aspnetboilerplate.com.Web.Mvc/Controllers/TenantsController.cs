using Abp.Application.Services.Dto;
using Abp.AspNetCore.Mvc.Authorization;
using aspnetboilerplate.com.Authorization;
using aspnetboilerplate.com.Controllers;
using aspnetboilerplate.com.MultiTenancy;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Web.Controllers;

[AbpMvcAuthorize(PermissionNames.Pages_Tenants)]
public class TenantsController : comControllerBase
{
    private readonly ITenantAppService _tenantAppService;

    public TenantsController(ITenantAppService tenantAppService)
    {
        _tenantAppService = tenantAppService;
    }

    public ActionResult Index() => View();

    public async Task<ActionResult> EditModal(int tenantId)
    {
        var tenantDto = await _tenantAppService.GetAsync(new EntityDto(tenantId));
        return PartialView("_EditModal", tenantDto);
    }
}
