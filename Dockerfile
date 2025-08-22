# --- runtime ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0
ENV ASPNETCORE_URLS=http://+:8080
WORKDIR /app
EXPOSE 8080

# copy contents (note the trailing slashes)
COPY --from=build /app/publish/ /app/
RUN chgrp -R 0 /app && chmod -R g=u /app

ENTRYPOINT ["dotnet","WebApp.dll"]


