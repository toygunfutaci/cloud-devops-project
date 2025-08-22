# --- build stage ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Tüm repo içeriğini kopyala ve restore/publish yap
COPY . .
RUN dotnet restore
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/publish

# --- runtime stage ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0
ENV ASPNETCORE_URLS=http://+:8080
WORKDIR /app
EXPOSE 8080

# build aşamasından yayın çıktısını kopyala
COPY --from=build /app/publish/ /app/
RUN chgrp -R 0 /app && chmod -R g=u /app

ENTRYPOINT ["dotnet","WebApp.dll"]



