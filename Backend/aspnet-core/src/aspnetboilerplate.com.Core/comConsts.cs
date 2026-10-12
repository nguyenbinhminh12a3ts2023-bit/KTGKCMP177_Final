using aspnetboilerplate.com.Debugging;

namespace aspnetboilerplate.com;

public class comConsts
{
    public const string LocalizationSourceName = "com";

    public const string ConnectionStringName = "Default";

    public const bool MultiTenancyEnabled = true;


    /// <summary>
    /// Default pass phrase for SimpleStringCipher decrypt/encrypt operations
    /// </summary>
    public static readonly string DefaultPassPhrase =
        DebugHelper.IsDebug ? "gsKxGZ012HLL3MI5" : "cae5479c9f0443b39ac6f2a4f53b4685";
}
