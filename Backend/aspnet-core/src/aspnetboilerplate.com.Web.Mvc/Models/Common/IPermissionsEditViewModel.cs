using aspnetboilerplate.com.Roles.Dto;
using System.Collections.Generic;

namespace aspnetboilerplate.com.Web.Models.Common;

public interface IPermissionsEditViewModel
{
    List<FlatPermissionDto> Permissions { get; set; }
}