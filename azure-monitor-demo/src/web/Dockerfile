# Multi-stage build for the .NET 8 Application Insights demo web app, hosted on Azure Container Instances.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore first (better layer caching)
COPY DemoMonitorApp.csproj ./
RUN dotnet restore DemoMonitorApp.csproj

# Copy the rest of the source
COPY . ./

# ProgramSimple.cs is an alternate entry point with duplicate top-level statements
# (CS8802). Remove it so only Program.cs compiles.
RUN rm -f ProgramSimple.cs

RUN dotnet publish DemoMonitorApp.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish ./

# ACI exposes plain HTTP; listen on 8080 (no HTTPS cert in the container).
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080

ENTRYPOINT ["dotnet", "DemoMonitorApp.dll"]
