# AutoTTU - Sistema de Gerenciamento de Motos

Sistema de gerenciamento de motos com API REST desenvolvido em ASP.NET Core 8.0, incluindo funcionalidades de check-in, gerenciamento de slots, usuários e análise de risco utilizando Machine Learning.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Funcionalidades](#funcionalidades)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Configuração](#instalação-e-configuração)
- [Como Executar](#como-executar)
- [Testes](#testes)
- [API Endpoints](#api-endpoints)
- [Autenticação](#autenticação)
- [Machine Learning](#machine-learning)
- [Deploy no Azure](#deploy-no-azure)
- [Contribuição](#contribuição)

## 🎯 Sobre o Projeto

O AutoTTU é uma API REST completa para gerenciamento de motos, permitindo:
- Cadastro e gerenciamento de usuários
- Cadastro e controle de motos
- Sistema de check-in com registro de danos
- Gerenciamento de slots de estacionamento
- Análise de risco utilizando Machine Learning (Microsoft ML.NET)
- Health checks para monitoramento
- Versionamento de API
- Documentação automática com Swagger

## 🛠 Tecnologias Utilizadas

- **.NET 8.0** - Framework principal
- **ASP.NET Core Web API** - Framework para construção da API
- **Entity Framework Core 9.0.4** - ORM para acesso a dados
- **SQL Server** - Banco de dados relacional
- **Microsoft ML.NET 4.0.3** - Machine Learning para análise de risco
- **Swagger/OpenAPI** - Documentação da API
- **Docker** - Containerização
- **Azure** - Cloud computing (ACR, ACI, Web App, SQL Database)
- **Azure Pipelines** - CI/CD
- **xUnit** - Framework de testes
- **FluentAssertions** - Asserções para testes
- **Moq** - Mocking para testes unitários

## ✨ Funcionalidades

### Gerenciamento de Usuários
- CRUD completo de usuários
- Sistema de login
- Validação de email único

### Gerenciamento de Motos
- CRUD completo de motos
- Controle de status (ativo/inativo)
- Armazenamento de fotos via URL
- Validação de placa única

### Sistema de Check-in
- Registro de check-ins com timestamp
- Upload de imagens
- Registro de observações
- Flag de violação/dano
- Análise de risco automática via IA

### Gerenciamento de Slots
- Controle de vagas de estacionamento
- Associação de motos aos slots
- Status de ocupação

### Machine Learning
- Análise preditiva de risco de danos
- Treinamento automático com dados históricos
- Detecção de palavras-chave relacionadas a danos
- Cálculo de probabilidade de risco

### Segurança
- Autenticação via API Key
- Middleware de validação de chave
- Rotas públicas (health check, swagger)

### Monitoramento
- Health checks para banco de dados
- Endpoint `/health` para verificação de status

## 📁 Estrutura do Projeto

```
DevOps_Sprint4/
├── AutoTTU/                          # Projeto principal
│   ├── Connection/                   # Contexto do Entity Framework
│   │   └── AppDbContext.cs
│   ├── Controllers/                  # Controllers da API
│   │   ├── CheckinsController.cs
│   │   ├── HealthController.cs
│   │   ├── MotosController.cs
│   │   ├── SlotsController.cs
│   │   └── UsuariosController.cs
│   ├── Dto/                          # Data Transfer Objects
│   │   ├── CheckinInputDto.cs
│   │   ├── LoginDto.cs
│   │   ├── MotoInputDto.cs
│   │   ├── SlotsInputDto.cs
│   │   └── UsuarioInputDto.cs
│   ├── Middleware/                   # Middlewares customizados
│   │   └── ApiKeyMiddleware.cs
│   ├── Migrations/                   # Migrations do Entity Framework
│   ├── ML/                           # Machine Learning
│   │   ├── CheckInData.cs
│   │   ├── ControllersML/
│   │   │   └── IAController.cs
│   │   └── ServicesML/
│   │       ├── IAService.cs
│   │       └── IIAService.cs
│   ├── Models/                       # Modelos de dados
│   │   ├── Checkin.cs
│   │   ├── Motos.cs
│   │   ├── Slot.cs
│   │   └── Usuario.cs
│   ├── Repository/                   # Camada de repositório
│   │   ├── CheckinRepository.cs
│   │   ├── ICheckinRepository.cs
│   │   ├── IMotosRepository.cs
│   │   ├── ISlotRepository.cs
│   │   ├── IUsuarioRepository.cs
│   │   ├── MotosRepository.cs
│   │   ├── SlotRepository.cs
│   │   └── UsuarioRepository.cs
│   ├── Service/                       # Camada de serviço
│   │   ├── CheckinService.cs
│   │   ├── ICheckinService.cs
│   │   ├── IMotosService.cs
│   │   ├── ISlotService.cs
│   │   ├── IUsuarioService.cs
│   │   ├── MotosService.cs
│   │   ├── SlotService.cs
│   │   └── UsuarioService.cs
│   ├── appsettings.json              # Configurações
│   ├── appsettings.Example.json      # Exemplo de configurações
│   └── Program.cs                    # Ponto de entrada
├── AutoTTU.Tests/                    # Projeto de testes
│   ├── Integration/                  # Testes de integração
│   │   ├── Controllers/
│   │   └── CustomWebApplicationFactory.cs
│   ├── Services/                     # Testes de serviço
│   └── Helpers/
├── Dockerfile                        # Configuração Docker
├── azure-pipelines.yml              # Pipeline CI/CD
├── autottuACR.sh                    # Script criação ACR
└── autottu-aci-webapp.sh           # Script deploy Azure
```

## 📦 Pré-requisitos

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [SQL Server](https://www.microsoft.com/sql-server) ou [Azure SQL Database](https://azure.microsoft.com/services/sql-database/)
- [Docker](https://www.docker.com/) (opcional, para containerização)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (para deploy no Azure)
- [Git](https://git-scm.com/)

## ⚙️ Instalação e Configuração

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd DevOps_Sprint4
```

### 2. Configure o banco de dados

Edite o arquivo `AutoTTU/appsettings.json` com suas credenciais:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=SEU_SERVIDOR;Database=AutoTTUDB;User Id=SEU_USUARIO;Password=SUA_SENHA;TrustServerCertificate=True;"
  },
  "ApiSettings": {
    "ApiKey": "SUA_API_KEY_AQUI"
  }
}
```

Ou copie o arquivo de exemplo:

```bash
cp AutoTTU/appsettings.Example.json AutoTTU/appsettings.json
```

### 3. Restaure as dependências

```bash
dotnet restore
```

### 4. Execute as migrations

```bash
cd AutoTTU
dotnet ef database update
```

## 🚀 Como Executar

### Executar localmente

```bash
cd AutoTTU
dotnet run
```

A API estará disponível em:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger: `http://localhost:5000` ou `https://localhost:5001`

### Executar com Docker

#### Build da imagem

```bash
docker build -t autottu:latest .
```

#### Executar container

```bash
docker run -p 8080:80 \
  -e ConnectionStrings__DefaultConnection="Sua_Connection_String" \
  -e ApiSettings__ApiKey="Sua_API_Key" \
  autottu:latest
```

## 🧪 Testes

### Executar todos os testes

```bash
dotnet test
```

### Executar testes com cobertura

```bash
dotnet test /p:CollectCoverage=true
```

### Tipos de Testes

- **Testes Unitários**: Testam serviços isoladamente
- **Testes de Integração**: Testam controllers com banco de dados em memória

## 📡 API Endpoints

### Versionamento

A API utiliza versionamento via URL, query string ou header:
- URL: `/api/v1/usuarios`
- Query: `/api/usuarios?api-version=1.0`
- Header: `x-api-version: 1.0`

### Endpoints Principais

#### Usuários (`/api/v1/usuarios`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/usuarios` | Lista todos os usuários |
| GET | `/api/v1/usuarios/{id}` | Busca usuário por ID |
| POST | `/api/v1/usuarios` | Cria novo usuário |
| PUT | `/api/v1/usuarios/{id}` | Atualiza usuário |
| DELETE | `/api/v1/usuarios/{id}` | Remove usuário |
| POST | `/api/v1/usuarios/Login` | Realiza login |

#### Motos (`/api/v1/motos`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/motos` | Lista todas as motos |
| GET | `/api/v1/motos/{id}` | Busca moto por ID |
| POST | `/api/v1/motos` | Cria nova moto |
| PUT | `/api/v1/motos/{id}` | Atualiza moto |
| DELETE | `/api/v1/motos/{id}` | Remove moto |

#### Check-ins (`/api/v1/checkins`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/checkins` | Lista todos os check-ins |
| GET | `/api/v1/checkins/{id}` | Busca check-in por ID |
| POST | `/api/v1/checkins` | Cria novo check-in |
| PUT | `/api/v1/checkins/{id}` | Atualiza check-in |
| DELETE | `/api/v1/checkins/{id}` | Remove check-in |

#### Slots (`/api/v1/slot`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/slot` | Lista todos os slots |
| GET | `/api/v1/slot/{id}` | Busca slot por ID |
| POST | `/api/v1/slot` | Cria novo slot |
| PUT | `/api/v1/slot/{id}` | Atualiza slot |
| DELETE | `/api/v1/slot/{id}` | Remove slot |

#### IA (`/api/v1/ia`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/api/v1/ia/prever-risco` | Prevê risco de uma observação |
| POST | `/api/v1/ia/prever-danos` | Analisa todos os check-ins e calcula estatísticas |

#### Health Check

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/health` | Verifica saúde da aplicação e banco de dados |

## 🔐 Autenticação

A API utiliza autenticação via API Key. Todas as requisições (exceto rotas públicas) devem incluir o header:

```
X-API-Key: SUA_API_KEY_AQUI
```

### Rotas Públicas (não requerem API Key)
- `/health`
- `/swagger`
- `/swagger/index.html`
- `/swagger/v1/swagger.json`

### Exemplo de Requisição

```bash
curl -X GET "https://api.exemplo.com/api/v1/usuarios" \
  -H "X-API-Key: SUA_API_KEY_AQUI" \
  -H "Content-Type: application/json"
```

## 🤖 Machine Learning

O sistema utiliza Microsoft ML.NET para análise preditiva de risco de danos em motos.

### Funcionalidades

1. **Análise de Observações**: Analisa o texto das observações dos check-ins para identificar risco de danos
2. **Treinamento Automático**: O modelo é treinado automaticamente com dados históricos de check-ins
3. **Detecção de Palavras-chave**: Identifica termos relacionados a danos (arranhado, quebrado, amassado, etc.)
4. **Probabilidade de Risco**: Retorna uma probabilidade de 0 a 1 indicando o risco de dano

### Endpoint de Predição

```bash
POST /api/v1/ia/prever-risco
Content-Type: application/json

"Tanque arranhado e retrovisor quebrado"
```

**Resposta:**
```json
{
  "observacao": "Tanque arranhado e retrovisor quebrado",
  "riscoAlto": true,
  "probabilidade": 0.85
}
```

### Endpoint de Análise Completa

```bash
POST /api/v1/ia/prever-danos
```

**Resposta:**
```json
{
  "totalCheckins": 10,
  "mediaProbabilidade": 0.65,
  "quantidadeRiscoAlto": 3,
  "percentualRiscoAlto": 30.0,
  "detalhes": [...]
}
```

## ☁️ Deploy no Azure

### Pré-requisitos

- Conta Azure ativa
- Azure CLI instalado e configurado
- Permissões para criar recursos no Azure

### 1. Criar Azure Container Registry (ACR)

```bash
bash autottuACR.sh
```

Este script cria:
- Grupo de recursos `rg-azuredevops-docker`
- Azure Container Registry `autottu`
- Habilita usuário administrador

### 2. Build e Push da Imagem

O pipeline do Azure DevOps (`azure-pipelines.yml`) faz automaticamente:
- Build da imagem Docker
- Push para o ACR
- Tag com `latest` e `Build.BuildId`

### 3. Criar Infraestrutura no Azure

```bash
bash autottu-aci-webapp.sh
```

Este script cria:
- SQL Server e Database Azure
- Configuração de firewall
- Azure Container Instance (ACI)
- Azure Web App
- Configuração de connection string

### 4. Configurar Variáveis de Ambiente no Web App

```bash
az webapp config appsettings set \
  --resource-group rg-azuredevops-docker \
  --name autottuwebapp \
  --settings ApiSettings__ApiKey="SUA_API_KEY"
```

### 5. Acessar a Aplicação

- **Web App**: `https://autottuwebapp.azurewebsites.net`
- **ACI**: `http://autottu.brazilsouth.azurecontainer.io`

## 🔄 CI/CD

O projeto utiliza Azure Pipelines para CI/CD automático:

1. **Trigger**: Push na branch `main`
2. **Build**: Compila a aplicação .NET
3. **Docker**: Cria imagem Docker
4. **Push**: Envia imagem para ACR
5. **Deploy**: (Configurar manualmente ou adicionar etapa)

Arquivo: `azure-pipelines.yml`

## 📝 Modelos de Dados

### Usuario
- `IdUsuario` (int, PK)
- `Nome` (string, required)
- `Email` (string, required, unique)
- `Senha` (string, required)
- `Telefone` (string, required)

### Motos
- `IdMoto` (int, PK)
- `Modelo` (string, required)
- `Marca` (string, required)
- `Ano` (int, required)
- `Placa` (string, unique)
- `AtivoChar` (string: "S" ou "N")
- `FotoUrl` (string)

### Slot
- `IdSlot` (int, PK)
- `IdMoto` (int, FK)
- `AtivoChar` (string: "S" ou "N")

### Checkin
- `IdCheckin` (int, PK)
- `IdMoto` (int, FK)
- `IdUsuario` (int, FK)
- `AtivoChar` (string: "S" ou "N") - indica se foi violada
- `Observacao` (string, required)
- `TimeStamp` (DateTime, required)
- `ImagensUrl` (string)

## 🏗 Arquitetura

O projeto segue os princípios de **Clean Architecture** e **Repository Pattern**:

- **Controllers**: Recebem requisições HTTP
- **Services**: Lógica de negócio
- **Repositories**: Acesso a dados
- **Models**: Entidades do domínio
- **DTOs**: Objetos de transferência de dados
- **Middleware**: Processamento de requisições (API Key)

## 🔍 Health Checks

O sistema inclui health checks para monitoramento:

- **Endpoint**: `/health`
- **Verifica**: Conexão com banco de dados
- **Status**: Healthy, Degraded, Unhealthy

## 📚 Documentação

A documentação da API está disponível via Swagger:

- **URL**: `http://localhost:5000` (ou URL do servidor)
- **Inclui**: Descrição de todos os endpoints, modelos de dados, exemplos de requisição/resposta

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é parte de um trabalho acadêmico/curso.

## 🧪 Integrantes do Projeto

## 📞 Suporte

Para questões e suporte, abra uma issue no repositório.

---


