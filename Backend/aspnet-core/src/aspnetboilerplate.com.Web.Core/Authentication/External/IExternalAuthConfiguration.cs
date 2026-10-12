using System.Collections.Generic;

namespace aspnetboilerplate.com.Authentication.External
{
    public interface IExternalAuthConfiguration
    {
        List<ExternalLoginProviderInfo> Providers { get; }
    }
}
