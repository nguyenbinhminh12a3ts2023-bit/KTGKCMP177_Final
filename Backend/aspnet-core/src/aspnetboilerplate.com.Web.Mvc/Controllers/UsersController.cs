using Abp.Application.Services.Dto;
using Abp.AspNetCore.Mvc.Authorization;
using aspnetboilerplate.com.Authorization;
using aspnetboilerplate.com.Controllers;
using aspnetboilerplate.com.Users;
using aspnetboilerplate.com.Web.Models.Users;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace aspnetboilerplate.com.Web.Controllers;

[AbpMvcAuthorize(PermissionNames.Pages_Users)]
public class UsersController : comControllerBase
{
    private readonly IUserAppService _userAppService;

    public UsersController(IUserAppService userAppService)
    {
        _userAppService = userAppService;
    }

    public async Task<ActionResult> Index()
    {
        var roles = (await _userAppService.GetRoles()).Items;
        var model = new UserListViewModel
        {
            Roles = roles
        };
        return View(model);
    }

    public async Task<ActionResult> EditModal(long userId)
    {
        var user = await _userAppService.GetAsync(new EntityDto<long>(userId));
        var roles = (await _userAppService.GetRoles()).Items;
        var model = new EditUserModalViewModel
        {
            User = user,
            Roles = roles
        };
        return PartialView("_EditModal", model);
    }

    public ActionResult ChangePassword()
    {
        return View();
    }
}
