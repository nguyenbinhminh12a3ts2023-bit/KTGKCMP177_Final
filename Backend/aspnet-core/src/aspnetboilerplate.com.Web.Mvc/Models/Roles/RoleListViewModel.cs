using aspnetboilerplate.com.Roles.Dto;
using System.Collections.Generic;

namespace aspnetboilerplate.com.Web.Models.Roles;

public class RoleListViewModel
{
    public IReadOnlyList<PermissionDto> Permissions { get; set; }
}
