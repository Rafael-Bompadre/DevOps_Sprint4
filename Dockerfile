# Etapa 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar o arquivo de projeto e restaurar dependências
COPY ["AutoTTU/AutoTTU.csproj", "AutoTTU/"]
RUN dotnet restore "AutoTTU/AutoTTU.csproj"

# Copiar todo o código fonte
COPY AutoTTU/. ./AutoTTU/

# Definir o diretório de trabalho para o projeto
WORKDIR /src/AutoTTU

# Compilar o projeto
RUN dotnet build "AutoTTU.csproj" -c Release -o /app/build

# Publicar a aplicação
RUN dotnet publish "AutoTTU.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copiar a aplicação publicada
COPY --from=build /app/publish .

# Expor a porta padrão
EXPOSE 80

# Configuração de ambiente
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80

# Comando para iniciar a aplicação
ENTRYPOINT ["dotnet", "AutoTTU.dll"]
