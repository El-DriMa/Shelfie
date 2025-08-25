FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Shelfie.Subscriber/Shelfie.Subscriber.csproj", "Shelfie.Subscriber/"]
COPY ["Shelfie.Models/Shelfie.Models.csproj", "Shelfie.Models/"]
RUN dotnet restore "Shelfie.Subscriber/Shelfie.Subscriber.csproj"
COPY . .
WORKDIR "/src/Shelfie.Subscriber"
RUN dotnet build "Shelfie.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Shelfie.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY Shelfie.Subscriber/appsettings.json .
ENTRYPOINT ["dotnet", "Shelfie.Subscriber.dll"]
