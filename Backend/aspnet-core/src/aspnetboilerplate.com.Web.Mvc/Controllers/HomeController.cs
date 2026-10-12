using Abp.AspNetCore.Mvc.Authorization;
using aspnetboilerplate.com.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace aspnetboilerplate.com.Web.Controllers;

[AbpMvcAuthorize]
public class HomeController : comControllerBase
{
    public ActionResult Index()
    {
        return View();
    }
}
