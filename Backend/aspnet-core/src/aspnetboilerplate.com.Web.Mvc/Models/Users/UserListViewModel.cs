using aspnetboilerplate.com.Roles.Dto;
using System.Collections.Generic;

namespace aspnetboilerplate.com.Web.Models.Users;

public class UserListViewModel
{
    public IReadOnlyList<RoleDto> Roles { get; set; }
}
