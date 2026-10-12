using Abp.Authorization;
using aspnetboilerplate.com.Authorization.Roles;
using aspnetboilerplate.com.Authorization.Users;

namespace aspnetboilerplate.com.Authorization;

public class PermissionChecker : PermissionChecker<Role, User>
{
    public PermissionChecker(UserManager userManager)
        : base(userManager)
    {
    }
}
