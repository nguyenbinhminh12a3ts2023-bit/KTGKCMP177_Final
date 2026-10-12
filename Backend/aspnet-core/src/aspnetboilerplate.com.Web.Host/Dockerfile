FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src
COPY ["src/aspnetboilerplate.com.Web.Host/aspnetboilerplate.com.Web.Host.csproj", "src/aspnetboilerplate.com.Web.Host/"]
COPY ["src/aspnetboilerplate.com.Web.Core/aspnetboilerplate.com.Web.Core.csproj", "src/aspnetboilerplate.com.Web.Core/"]
COPY ["src/aspnetboilerplate.com.Application/aspnetboilerplate.com.Application.csproj", "src/aspnetboilerplate.com.Application/"]
COPY ["src/aspnetboilerplate.com.Core/aspnetboilerplate.com.Core.csproj", "src/aspnetboilerplate.com.Core/"]
COPY ["src/aspnetboilerplate.com.EntityFrameworkCore/aspnetboilerplate.com.EntityFrameworkCore.csproj", "src/aspnetboilerplate.com.EntityFrameworkCore/"]
WORKDIR "/src/src/aspnetboilerplate.com.Web.Host"
RUN dotnet restore 

WORKDIR /src
COPY ["src/aspnetboilerplate.com.Web.Host", "src/aspnetboilerplate.com.Web.Host"]
COPY ["src/aspnetboilerplate.com.Web.Core", "src/aspnetboilerplate.com.Web.Core"]
COPY ["src/aspnetboilerplate.com.Application", "src/aspnetboilerplate.com.Application"]
COPY ["src/aspnetboilerplate.com.Core", "src/aspnetboilerplate.com.Core"]
COPY ["src/aspnetboilerplate.com.EntityFrameworkCore", "src/aspnetboilerplate.com.EntityFrameworkCore"]
WORKDIR "/src/src/aspnetboilerplate.com.Web.Host"
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80
WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "aspnetboilerplate.com.Web.Host.dll"]
