using Abp.AutoMapper;
using aspnetboilerplate.com.Roles.Dto;
using aspnetboilerplate.com.Web.Models.Common;

namespace aspnetboilerplate.com.Web.Models.Roles;

[AutoMapFrom(typeof(GetRoleForEditOutput))]
public class EditRoleModalViewModel : GetRoleForEditOutput, IPermissionsEditViewModel
{
    public bool HasPermission(FlatPermissionDto permission)
    {
        return GrantedPermissionNames.Contains(permission.Name);
    }
}
