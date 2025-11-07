# Guia de Configuração do Azure Pipelines para AutoTTU

Este documento descreve como configurar o CI/CD no Azure DevOps para o projeto AutoTTU.

## 📋 Pré-requisitos

1. **Azure Container Registry (ACR)** criado usando o script `infraACR.sh`
2. **Azure Web App** criado usando o script `infra-aci-webapp.sh`
3. **Repositório** no Azure DevOps ou GitHub conectado ao Azure DevOps
4. **Service Connection** configurada no Azure DevOps para acessar o ACR

## 🔧 Passo 1: Executar Scripts de Infraestrutura

### 1.1 Criar o Azure Container Registry

```bash
# Edite o script infraACR.sh e altere:
# - rm=rm9999 (substitua pelo seu RM)
# - regiao (se necessário)

# Execute o script
bash infraACR.sh
```

**Importante:** Anote as credenciais exibidas (`ACR_ADMIN_USER` e `ACR_ADMIN_PASSWORD`).

### 1.2 Criar o Azure Web App

```bash
# Edite o script infra-aci-webapp.sh e altere:
# - rm=rm9999 (substitua pelo seu RM)
# - regiao (se necessário)

# Execute o script
bash infra-aci-webapp.sh
```

## 🔗 Passo 2: Configurar Service Connection no Azure DevOps

1. Acesse o Azure DevOps → **Project Settings** → **Service connections**
2. Clique em **New service connection**
3. Selecione **Docker Registry**
4. Escolha **Azure Container Registry**
5. Preencha:
   - **Subscription**: Selecione sua assinatura Azure
   - **Azure container registry**: Selecione o ACR criado (`autottu<seu-rm>`)
   - **Service connection name**: `autottu-acr` (ou outro nome de sua preferência)
6. Clique em **Save**

## 🚀 Passo 3: Criar Pipeline no Azure DevOps

### 3.1 Criar Nova Pipeline

1. No Azure DevOps, vá para **Pipelines** → **New Pipeline**
2. Selecione o repositório (Azure Repos, GitHub, etc.)
3. Escolha **Starter pipeline** ou **Docker** template

### 3.2 Configuração da Pipeline (YAML)

A pipeline deve ter as seguintes etapas:

#### Etapa 1: Build da Imagem Docker
```yaml
trigger:
  branches:
    include:
      - main
      - master

pool:
  vmImage: 'ubuntu-latest'

variables:
  dockerRegistryServiceConnection: 'autottu-acr'  # Nome da Service Connection
  imageRepository: 'autottu'
  containerRegistry: 'autottu<seu-rm>.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: 'Build and Push Docker Image'
  jobs:
  - job: Docker
    displayName: 'Build Docker Image'
    steps:
    - task: Docker@2
      displayName: 'Build and push image'
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
          latest
```

#### Etapa 2: Deploy para Azure Web App (Opcional - adicione após o build)
```yaml
- stage: Deploy
  displayName: 'Deploy to Azure Web App'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployWebApp
    displayName: 'Deploy to Web App'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebAppContainer@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Your-Azure-Subscription-Service-Connection'
              appName: 'autottuwebapp<seu-rm>'
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'
```

### 3.3 Variáveis de Pipeline (Recomendado)

Configure as seguintes variáveis no Azure DevOps:

1. Vá para **Pipelines** → **Library** → **Variable groups** (ou use variáveis do pipeline)
2. Crie variáveis:
   - `ACR_NAME`: `autottu<seu-rm>`
   - `IMAGE_NAME`: `autottu`
   - `WEB_APP_NAME`: `autottuwebapp<seu-rm>`

## ⚙️ Passo 4: Configurar Variáveis de Ambiente no Azure Web App

No Azure Portal, configure as seguintes variáveis de ambiente no Web App:

1. Acesse o **Azure Portal** → **App Services** → Seu Web App
2. Vá em **Configuration** → **Application settings**
3. Adicione as seguintes variáveis:

```
ConnectionStrings__DefaultConnection = "Server=tcp:SEU_SERVIDOR.database.windows.net,1433;Initial Catalog=SEU_BANCO;Persist Security Info=False;User ID=SEU_USUARIO;Password=SUA_SENHA;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

ApiSettings__ApiKey = "SUA_API_KEY_AQUI"

ASPNETCORE_ENVIRONMENT = "Production"
```

**Nota:** Use `__` (dois underscores) para separar seções aninhadas no JSON.

## 🔍 Passo 5: Testar a Pipeline

1. Faça um commit e push para o branch `main` ou `master`
2. A pipeline deve ser acionada automaticamente
3. Verifique os logs em **Pipelines** → Selecione a execução
4. Após o build bem-sucedido, a imagem será enviada para o ACR
5. O Web App deve fazer pull automático da imagem (se configurado) ou você pode fazer deploy manual

## 📝 Estrutura do Projeto para CI/CD

O projeto está preparado com:

- ✅ **Dockerfile** otimizado para build multi-stage
- ✅ **.dockerignore** configurado para excluir arquivos desnecessários
- ✅ **Estrutura de pastas** compatível com Docker
- ✅ **Configuração de porta** (80) para Azure Web App
- ✅ **Variáveis de ambiente** configuráveis via Azure Portal

## 🐛 Troubleshooting

### Problema: Pipeline falha no build
- Verifique se o Dockerfile está no diretório raiz
- Verifique se o caminho do Dockerfile está correto na pipeline
- Verifique os logs de build para erros específicos

### Problema: Erro ao fazer push para ACR
- Verifique se a Service Connection está configurada corretamente
- Verifique se as credenciais do ACR estão corretas
- Verifique se o nome do ACR está correto na pipeline

### Problema: Web App não inicia
- Verifique se a variável `WEBSITES_PORT=80` está configurada
- Verifique se a connection string do SQL Server está configurada
- Verifique os logs do Web App no Azure Portal

### Problema: Erro de conexão com banco de dados
- Verifique se o firewall do SQL Server Azure permite conexões do Azure Services
- Verifique se a connection string está correta
- Verifique se o banco de dados existe e as migrations foram executadas

## 📚 Recursos Adicionais

- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)

