# Use a imagem base do .NET 8.0 SDK para build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar arquivos do projeto e restaurar dependências (cache layer)
COPY ["AutoTTU/AutoTTU.csproj", "AutoTTU/"]
RUN dotnet restore "AutoTTU/AutoTTU.csproj"

# Copiar todo o código fonte e fazer o build
COPY . .
WORKDIR "/src/AutoTTU"
RUN dotnet build "AutoTTU.csproj" -c Release -o /app/build --no-restore

# Publicar a aplicação
FROM build AS publish
RUN dotnet publish "AutoTTU.csproj" -c Release -o /app/publish /p:UseAppHost=false --no-restore

# Imagem final para runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copiar os arquivos publicados
COPY --from=publish /app/publish .

# Expor a porta 80 (padrão do Azure Web App)
EXPOSE 80

# Definir variável de ambiente para produção
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80

# Comando para executar a aplicação
ENTRYPOINT ["dotnet", "AutoTTU.dll"]

